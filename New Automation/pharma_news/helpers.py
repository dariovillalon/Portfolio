"""Helpers for pharma_news package."""
import hashlib
import itertools
import logging
import random
import re
import shutil
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import List

import feedparser
import google
import pandas as pd
from azure.storage.blob import BlobServiceClient
from gnews import GNews
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from pharma_news.cfg import (
    AZURE_CONN_STR,
)
from pharma_news.constants import (
    AZURE_BLOB_STORAGE_CONTAINER,
    GOOGLE_SERVICE_ACCOUNT_DIR,
    MAPPER_SHEET_ID,
    TMP_DIR,
    USER_AGENTS,
)

USER_AGENT = random.choice(USER_AGENTS)
GOOGLE_NEWS_URL = "https://news.google.com"
BASE_URL = "{0}/rss".format(GOOGLE_NEWS_URL)


class GNewsParser(GNews):

    def get_full_article(self, url: str):
        try:
            from newspaper import Article

            article = Article(url="%s" % url, language=self._language)
            article.download()
            article.parse()
        except Exception as error:
            logger = logging.getLogger(__name__)
            logger.error(error.args[0])
            return None
        return article

    def get_news(self, key):
        """
        :return: JSON response as nested Python dictionary.
        """
        if key:
            key = "%20".join(key.split(" "))
            url = BASE_URL + '/search?q={}'.format(key) + self._ceid()
            return self._get_news(url)

    def _get_news(self, url):
        try:
            if self._proxy:
                proxy_handler = urllib.request.ProxyHandler(self._proxy)
                feed_data = feedparser.parse(
                    url, agent=USER_AGENT, handlers=[proxy_handler]
                )
            else:
                feed_data = feedparser.parse(url, agent=USER_AGENT)

            return [
                item
                for item in map(self._process, feed_data.entries[: self._max_results])
                if item
            ]
        except Exception as err:
            logging.info(err.args[0])
            return []


def hash_url(article_url: str) -> str:
    """Hash URLs.

    Parameters
    ----------
    article_url : str
        Article URL.

    Returns
    -------
    hex_dig : str
        Hashed URL.

    """
    hash_object = hashlib.sha256(article_url.encode('utf-8'))
    hex_dig = hash_object.hexdigest()
    return hex_dig


def upload_news_df_to_blob_storage(df_to_write: pd.DataFrame, indication: str, source: str, keyword: str, **kwargs):
    """Upload a given DataFrame to a Blob Storage.

    Parameters
    ----------
    indication : str
        Indication for keywords used in current extraction.
    df_to_write: pd.DataFrame
        DataFrame to be uploaded to Blob Storage.
    source: str
        Site name from which news articles was extracted.
    keyword : str
        Topic or keyword used in the articles extraction.
    """
    logging.info(f"Going to save {source} data..")
    logging.info(df_to_write.head())
    logging.info(df_to_write.columns)

    connect_str = AZURE_CONN_STR
    container_name = AZURE_BLOB_STORAGE_CONTAINER
    blob_service_client = BlobServiceClient.from_connection_string(connect_str)

    blob_prefix = get_blob_prefix(indication, source, keyword, **kwargs)

    for i in df_to_write.index:
        article_id = df_to_write.loc[i].id
        blob_name = get_blob_filename(
            indication, source, keyword, article_id, **kwargs
        )
        blob_client = blob_service_client.get_blob_client(
            container=container_name,
            blob=f"{blob_prefix}{blob_name}",
        )
        blob_client.upload_blob(
            df_to_write.loc[i].to_json(date_format='iso'), overwrite=True
        )


def cleanup_csv_files(**kwargs):
    """Clean tmp csv files located in tmp folder."""
    tmp_file_path = get_tmp_file_path(**kwargs)
    logging.info(f"Cleaning csv files from {tmp_file_path}")
    for f in Path(tmp_file_path).glob('*.csv'):
        logging.info(f"Removing {f} ..")
        f.unlink()
    for f in Path(tmp_file_path).glob('*.json'):
        logging.info(f"Removing {f} ..")
        f.unlink()
    logging.info("Cleaning pickle files..")
    for f in Path(tmp_file_path).glob('*.pkl'):
        logging.info(f"Removing {f} ..")
        f.unlink()

    tmp_file_path_is_empty = not any(tmp_file_path.iterdir())
    if tmp_file_path_is_empty:
        shutil.rmtree(tmp_file_path)

    logging.info("All finished, see you next time! :)")


def clean_html(raw_html: str):
    """Clean HTML content.

    Parameters
    ----------
    raw_html : str
        HTML code.

    Returns
    -------
    cleantext : str
        Cleaned text.

    """
    cleanr = re.compile("<.*?>")
    cleantext = re.sub(cleanr, "", raw_html)
    cleantext = cleantext.replace("\n", " ").replace("\xa0", " ")
    return cleantext


def get_values_from_sheet_api(spreadsheet_id, range_name):
    """Get data from gsheets API.

        Parameters
        ----------
        spreadsheet_id : string
            sheet id from target file to download.
        range_name : string
            range of rows from target file to download.

        Returns
        -------
        List[str]
            List of extracted rows.
    """
    creds, _ = google.auth.load_credentials_from_file(GOOGLE_SERVICE_ACCOUNT_DIR)

    try:
        service = build("sheets", "v4", credentials=creds)

        logging.info(f"Going to read from Gsheets API: sheet_id: {spreadsheet_id} range: {range_name}")
        result = service.spreadsheets().values().get(
            spreadsheetId=spreadsheet_id, range=range_name).execute()
        rows = result.get("values", [])
        logging.info(f"{len(rows)} rows retrieved")
        return rows

    except HttpError as error:
        logging.error(f"An error occurred: {error}")
        raise error


def get_indication_keywords_conf(skip_leading_rows=1) -> List[dict]:
    """Get desired keywords from gsheets API.

    Parameters
    ----------
    skip_leading_rows : str

    Returns
    -------
    List[dict]
        dicts with indications conf and keywords.
    """

    sheet_id = MAPPER_SHEET_ID["indication_keywords"]
    sheet_name = "indication_keywords"
    result = []

    conf_data = get_values_from_sheet_api(sheet_id, sheet_name)

    if len(conf_data) > 0:
        conf_data = conf_data[skip_leading_rows::]

    for c in conf_data:
        indication_conf = {}
        therapeutic_area = c[0]
        indication = c[1]
        keywords_sheet_id = c[2]
        keywords = get_values_from_sheet_api(keywords_sheet_id, "keywords")
        galert_conf = get_values_from_sheet_api(keywords_sheet_id, "urls_google_alerts")
        galert_input = []

        if len(keywords) > 0:
            # skip headers.
            keywords = keywords[1::]
            # Flat list of list.
            keywords = list(itertools.chain(*keywords))

        if len(galert_conf) > 0:
            # skip headers.
            galert_conf = galert_conf[1:]

            for gconf in galert_conf:
                try:
                    galert_input.append(gconf[1])
                except IndexError as err:
                    logging.error(f"Error trying to read values from google sheet conf file: {gconf}, error: {gconf}")

        indication_conf["indication"] = indication
        indication_conf["therapeutic_area"] = therapeutic_area
        indication_conf["clinical_trials"] = keywords
        indication_conf["google_news"] = keywords
        indication_conf["google_alerts"] = galert_input

        result.append(indication_conf)

    return result


def get_string_filepath_safe(unsafe_str: str) -> str:
    """
    Remove 'unsafe' chars from filepath dir.

    Parameters
    ----------
    unsafe_str : str

    Returns
    -------
    str
        Valid filepath.
    """

    safe_str = "".join(c if c.isalnum() else "-" for c in unsafe_str)
    return safe_str


def get_tmp_file_path(**kwargs) -> Path:
    """Get path to tmp files using Airflow default kwargs

    Returns
    -------
    Path
        Path to tmp files
    """
    execution_date = datetime.fromisoformat(kwargs['ts'])
    date_path = f"{execution_date.date().strftime('%Y%m%d')}-{execution_date.hour}"
    dag_id = kwargs["dag"].dag_id

    tmp_file_path = Path(TMP_DIR / dag_id / date_path)
    tmp_file_path.mkdir(parents=True, exist_ok=True)

    return tmp_file_path


def get_tmp_filename(indication: str, source_name: str, keyword: str, **kwargs) -> str:
    """Get path to tmp files using Airflow default kwargs

    Parameters
    ----------
    indication : str
        Indication for keywords used in current extraction.
    source_name : str
        Source name from which to extract news articles.
    keyword : str
        Topic or keywords used in the articles extraction.

    Returns
    -------
    str
        File's name
    """
    execution_date = datetime.fromisoformat(kwargs["ts"])
    date_write = f"{execution_date.date().strftime('%Y%m%d')}-{execution_date.hour}"

    indication = get_string_filepath_safe(indication).lower()
    source_name = get_string_filepath_safe(source_name).lower()
    keyword = get_string_filepath_safe(keyword).lower()

    tmp_filename = f"{indication}_{source_name}_{keyword}_{date_write}_df.json"
    return tmp_filename


def get_blob_prefix(indication: str, source_name: str, keyword: str, **kwargs) -> str:
    """Get Azure Blob prefix

    Parameters
    ----------
    indication : str
        Indication for keywords used in current extraction.
    source_name : str
        Site name from which to extract news articles.
    keyword : str
        Topic or keywords used in the articles extraction.

    Returns
    -------
    str
        Blob Prefix
    """

    execution_date = datetime.fromisoformat(kwargs["ts"])
    date_write = f"{execution_date.date().strftime('%Y%m%d')}"

    indication = get_string_filepath_safe(indication).lower()
    source_name = get_string_filepath_safe(source_name).lower()
    keyword = get_string_filepath_safe(keyword).lower()

    blob_prefix = f"{indication}/{source_name}/{date_write}/{keyword}/"

    return blob_prefix


def get_blob_filename(indication: str, source_name: str, keyword: str, article_id: str, **kwargs) -> str:
    """Get path to tmp files using Airflow default kwargs

    Parameters
    ----------
    indication : str
        Indication for keywords used in current extraction.
    source_name : str
        Source name from which to extract news articles.
    keyword : str
        Topic or keywords used in the articles extraction.
    article_id : str
        Article id.

    Returns
    -------
    str
        File's name
    """
    execution_date = datetime.fromisoformat(kwargs["ts"])
    date_write = f"{execution_date.date().strftime('%Y%m%d')}"

    indication = get_string_filepath_safe(indication).lower()
    source_name = get_string_filepath_safe(source_name).lower()
    keyword = get_string_filepath_safe(keyword).lower()

    blob_filename = f"{indication}_{source_name}_{date_write}_{keyword}_{article_id}.json"
    return blob_filename


def clean_clinicaltrials_summary_field(summary_field: str) -> pd.DataFrame:
    """Clean clinicaltrials summary field.

    Parameters
    ----------
    summary_field : str
        Series containing clinicaltrials summary field

    Returns
    -------
    pd.Series
        Cleaned clinicaltrials summary field
    """
    summary_field_str = re.sub(
        r"[^>]+</b>:?",
        "",
        summary_field,
        count=3
    )

    summary_field_str = summary_field_str.split("<b>")[1:]

    summary_field_df = pd.DataFrame.from_dict(
        {
            "conditions": [clean_html(summary_field_str[0]).strip()],
            "intervention": [clean_html(summary_field_str[1]).strip()],
            "sponsor": [clean_html(summary_field_str[2]).strip()],
            "status": [clean_html(summary_field_str[3]).strip()]
        }
    )

    return summary_field_df


def get_url_from_galert_feed_entry(galert_link):
    """
    Return news url from galert galert link.
    :param galert_link: str
    :return:
    """
    url = galert_link.split("url=")[-1].split("&")[0]

    return url
