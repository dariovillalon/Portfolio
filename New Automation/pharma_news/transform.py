"""Extract module for news."""
import datetime as dt
import pandas as pd

from typing import List, Tuple, Union
from newspaper import Article

from pharma_news.helpers import clean_clinicaltrials_summary_field, hash_url, get_url_from_galert_feed_entry


def transform_gnews_articles(
        news_and_articles: List[Tuple[dict, Article]]
) -> Union[pd.DataFrame, None]:
    """Transform news articles from GNews into a DataFrame.

    Parameters
    ----------
    news_and_articles : List[Tuple[dict, Article]]
        List with news articles extracted from GNews

    Returns
    -------
    Union[pd.DataFrame, None]
        DataFrame that contains all extracted news
    """
    google_news_df = None

    if not news_and_articles:
        return google_news_df

    google_news_df = pd.DataFrame()
    for news, article in news_and_articles:

        news_df = pd.json_normalize(news)[
            [
                "title",
                "url",
                "published date",
                "description",
                "publisher.title",
                "publisher.href"
            ]
        ]

        # Not always an article is retrieved
        article_columns = ["text"]
        if article:
            article_df = pd.DataFrame([article.__dict__])[article_columns]
        else:
            article_df = pd.DataFrame(columns=article_columns)

        news_and_articles_df = pd.concat(
            [news_df, article_df], axis=1
        )

        google_news_df = pd.concat(
            [google_news_df, news_and_articles_df], axis=0, ignore_index=True
        )

    google_news_df["published date"] = google_news_df["published date"].apply(
        lambda x: pd.to_datetime(
            x, format="%a, %d %b %Y %H:%M:%S %Z", errors="coerce"
        ).strftime("%Y/%m/%d %H:%M:%S")
    )

    google_news_df['id'] = google_news_df['url'].apply(lambda x: hash_url(x))

    google_news_df = google_news_df.rename(
        columns={
            "published date": "published_at",
            "publisher.title": "publisher",
            "publisher.href": "publisher_site",
            "url": "link",
        }
    )

    return google_news_df


def transform_clinicaltrials_articles(
        news_list: List[dict]
) -> Union[pd.DataFrame, None]:
    """Transform news articles from ClinicalTrials into a DataFrame.

    Parameters
    ----------
    news_list : List[dict]
        List with news articles extracted from ClinicalTrials

    Returns
    -------
    Union[pd.DataFrame, None]
        DataFrame that contains all extracted news
    """
    clinicaltrials_news_df = None

    if not news_list:
        return clinicaltrials_news_df

    clinicaltrials_news_df = pd.DataFrame(news_list)[
        [
            "title",
            "link",
            "summary",
            "id",
            "published"
        ]
    ]

    summary_expanded = pd.concat(
        clinicaltrials_news_df["summary"].apply(
            clean_clinicaltrials_summary_field
        ).values.tolist(),
        ignore_index=True
    )

    clinicaltrials_news_df = clinicaltrials_news_df.drop(columns=['summary'])

    clinicaltrials_news_df = pd.concat(
        [clinicaltrials_news_df, summary_expanded], axis=1
    )

    clinicaltrials_news_df["published"] = clinicaltrials_news_df["published"].apply(
        lambda x: pd.to_datetime(
            x, format="%a, %d %b %Y %H:%M:%S EDT", errors="coerce"
        ).strftime("%Y/%m/%d %H:%M:%S") if "EDT" in x
        else pd.to_datetime(
            x, format="%a, %d %b %Y %H:%M:%S EST", errors="coerce"
        ).strftime("%Y/%m/%d %H:%M:%S")
    )

    clinicaltrials_news_df = clinicaltrials_news_df.rename(
        columns={
            "sponsor": "publisher",
            "published": "published_at",
        }
    )

    return clinicaltrials_news_df


def transform_galerts_articles(alerts_and_articles: List[Tuple[dict, Article]]) -> Union[pd.DataFrame, None]:
    """Transform feed entries and articles from Google Alerts into a DataFrame.

    Parameters
    ----------
    alerts_and_articles : List[Tuple[dict, Article]]
        List with news entries and articles extracted from Google Alerts.

    Returns
    -------
    Union[pd.DataFrame, None]
        DataFrame that contains all extracted galerts new data.
    """

    if not alerts_and_articles:
        return

    galerts_df = pd.DataFrame()

    for feed_entry, article in alerts_and_articles:

        url = get_url_from_galert_feed_entry(feed_entry["link"])

        parsed_entry = {
            "id": hash_url(url),
            "feed_url": feed_entry["link"],
            "url": url,
            "title": feed_entry["title"],
            "published_at": feed_entry["published"],
            "summary": feed_entry["summary"],
        }

        alert_df = pd.DataFrame(parsed_entry)

        # Not always an article is retrieved
        article_columns = ["text", "source_url"]
        if article:
            article_df = pd.DataFrame([article.__dict__])[article_columns]
        else:
            article_df = pd.DataFrame(columns=article_columns)

        alerts_and_articles_df = pd.concat(
            [alert_df, article_df], axis=1
        )

        galerts_df = pd.concat(
            [galerts_df, alerts_and_articles_df], axis=0, ignore_index=True
        )

    galerts_df["published_at"] = galerts_df["published_at"].apply(
        lambda x: pd.to_datetime(
            x, format="%a, %d %b %Y %H:%M:%S %Z", errors="coerce"
        ).strftime("%Y/%m/%d %H:%M:%S")
    )

    galerts_df = galerts_df.rename(columns={"source_url": "publisher"})

    return galerts_df


def transform_articles_df(
        news_df: pd.DataFrame,
        source_name: str,
        indication: str,
        therapeutic_area: str,
        keyword: str,
) -> pd.DataFrame:
    """Transform articles DF with auxiliary columns related to the search

    Parameters
    ----------
    news_df : pd.DataFrame
        Article to be transformed
    source_name : str
        Source name from which to extract news articles.
    indication : str
        Indication for keywords used in current extraction.
    therapeutic_area: str
        Therapeutic area related to current indication.
    keyword : str
        Topic or keywords used in the extraction search.

    Returns
    -------
    pd.DataFrame
        Transformed Article DataFrame
    """
    news_df["source"] = source_name
    news_df["keyword"] = keyword
    news_df["indication"] = indication
    news_df["therapeutic_area"] = therapeutic_area
    news_df["updated_at"] = dt.datetime.utcnow()

    return news_df
