"""Extract module for extractions"""
import logging
from typing import List, Tuple

import feedparser
import pandas as pd
from newspaper import Article

from pharma_news.helpers import (
    GNewsParser,
    USER_AGENT, get_url_from_galert_feed_entry,
)


def get_data_from_clinicaltrials(keyword: str) -> List[dict]:
    """Get data from RSS about clinicaltrials.gov according to a certain topic.

    Parameters
    ----------
    keyword : str
        Topic of interest.

    Returns
    -------
    List[dict]
        List with jsons containing the data from clinicaltrials.
    """
    keyword = keyword.replace("_", "%20")

    logging.info(f"Going to extract clinicaltrials data about keyword {keyword}")

    url = f"https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=100&cond={keyword}&count=10000"  # noqa: E501, pylint: disable=line-too-long
    feed = feedparser.parse(url.replace(" ", "%20"))

    return feed.entries


def get_data_from_gnews(keyword: str) -> List[Tuple[dict, Article]]:
    """Get data from GNews according to a certain topic.

    Parameters
    ----------
    keyword : str
        keyword of interest.

    Returns
    -------
    news_and_articles : List[Tuple[dict, Article]]
        List with GNews news objects and Articles objects as tuples
    """
    logging.info(f"Going to extract gnews data about topic {keyword}")

    google_news = GNewsParser()
    json_resp = google_news.get_news(keyword)

    articles = [
        google_news.get_full_article(news["url"])
        for news in json_resp
    ]

    logging.info(f"{len(json_resp)} news extracted.")

    news_and_articles = [*zip(json_resp, articles)]

    return news_and_articles


def get_data_from_galerts(galert_feed_url: str):
    """

    Parameters
    ----------
    galert_feed_url

    Returns
    -------
    alerts_and_articles : List[Tuple[dict, Article]]
        List with Google Alerts objects and Articles objects as tuples.
    """

    articles = []
    parser = GNewsParser()

    feed_data = feedparser.parse(galert_feed_url, agent=USER_AGENT)

    for entry in feed_data.entries:
        news_url = get_url_from_galert_feed_entry(entry["link"])
        article = parser.get_full_article(news_url)
        articles.append(article)

    logging.info(f"{len(feed_data.entries)} entries extracted from Google Alert RSS.")

    alerts_and_articles = [*zip(feed_data.entries, articles)]

    return alerts_and_articles


# if __name__ == '__main__':
#     feed_url = "https://www.google.com/alerts/feeds/02573713762972252284/5379222760676706891"
#     res = get_data_from_galerts(feed_url)
#     pass