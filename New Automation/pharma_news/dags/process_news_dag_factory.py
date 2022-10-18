"""
This file holds the DAG Factory
"""
import json
import logging
from datetime import datetime

import pandas as pd
from airflow import DAG
from airflow.decorators import task
from airflow.exceptions import AirflowSkipException
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from azure.storage.blob import BlobServiceClient

from pharma_news.cfg import AZURE_CONN_STR, MONGODB_COLLECTION_NAME
from pharma_news.constants import AZURE_BLOB_STORAGE_CONTAINER
from pharma_news.dags.dags_helper import (
    DEFAULT_ARGS_COMMONS,
    EXTRACTION_MAPPER,
    TRANSFORMATION_MAPPER
)
from pharma_news.db_helpers import get_mongodb_conn
from pharma_news.helpers import (
    cleanup_csv_files,
    get_tmp_file_path,
    get_tmp_filename,
    upload_news_df_to_blob_storage,
    get_blob_prefix,
)
from pharma_news.schemas import MONGODB_COLUMNS
from pharma_news.transform import transform_articles_df


@task
def get_data_task(
    indication: str, source_name: str, keyword: str, therapeutic_area: str, **kwargs
) -> None:
    """Get data from a given site_name and for a given topic.

    Parameters
    ----------
    indication : str
        Indication for keywords used in current extraction.
    source_name : str
        Site name from which to extract news articles.
    therapeutic_area: str
        Therapeutic area related to current indication.
    keyword : str
        Topic or keywords used in the extraction search.

    Returns
    -------
    None
    """

    logging.info(f"Extracting data for indication: {indication}, source: {source_name}, TA: {therapeutic_area}, keyword: {keyword} ")

    tmp_file_path = get_tmp_file_path(**kwargs)
    target_fname = get_tmp_filename(indication, source_name, keyword, **kwargs)

    extraction_function = EXTRACTION_MAPPER[source_name]
    articles_list = extraction_function(keyword)

    if not articles_list:
        logging.info(f"Skipping... No new news articles found for {source_name}-{keyword}")
        raise AirflowSkipException

    transformation_function = TRANSFORMATION_MAPPER[source_name]
    news_df = transformation_function(articles_list)

    news_df = transform_articles_df(
        news_df=news_df,
        source_name=source_name,
        therapeutic_area=therapeutic_area,
        indication=indication,
        keyword=keyword,
    )

    logging.info(f"{news_df.info()}")
    logging.info(f"Writing temp file {target_fname}")
    news_df.to_json(tmp_file_path / target_fname)


@task
def load_data_to_blob_storage_task(indication: str, source_name: str, keyword: str, **kwargs) -> None:
    """Load a json to Blob Storage.

    Parameters
    ----------
    indication : str
        Indication for keywords used in current extraction.
    source_name : str
        Site name from which to extract news articles.
    keyword : str
        Topic or keywords used in the extraction search.

    Returns
    -------
    None
    """
    tmp_file_path = get_tmp_file_path(**kwargs)
    tmp_filename = get_tmp_filename(indication, source_name, keyword, **kwargs)

    logging.info(f"Reading temp file: {tmp_filename}")
    if (tmp_file_path / tmp_filename).exists():
        df_to_load = pd.read_json(tmp_file_path / tmp_filename, dtype=object)
        upload_news_df_to_blob_storage(df_to_load, indication, source_name, keyword, **kwargs)
    else:
        logging.info(f"No json file found for {source_name}-{keyword}")
        raise AirflowSkipException


@task
def load_data_to_mongodb_task(indication: str, source_name: str, keyword: str, **kwargs):
    """Read from blob storage for a certain date and topic. Load data to MongoDB.

    Parameters
    ----------
    indication : str
        Indication for input_data used in current extraction.
    source_name : str
        Source name from which to extract news articles.
    keyword : str
        Topic or keywords used in the extraction search.
    """

    logging.info(f"Going to load data from {source_name} about topic {keyword}")

    connect_str = AZURE_CONN_STR
    container_name = AZURE_BLOB_STORAGE_CONTAINER

    # MongoDB client.
    db = get_mongodb_conn()
    collection = db[MONGODB_COLLECTION_NAME]

    blob_service_client = BlobServiceClient.from_connection_string(connect_str)
    container_client = blob_service_client.get_container_client(container_name)

    blob_prefix = get_blob_prefix(indication, source_name, keyword, **kwargs)

    list_files = [f["name"] for f in container_client.walk_blobs(blob_prefix, delimiter="/")]

    if not list_files:
        logging.info(f"No blob found in path: {blob_prefix}")
        raise AirflowSkipException

    for blob in list_files:
        blob_client = blob_service_client.get_blob_client(
            container=container_name,
            blob=blob,
        )
        downloader = blob_client.download_blob()
        file_reader = json.loads(downloader.readall())

        try:
            article_df = pd.json_normalize(file_reader)

            logging.info(f"{article_df.info()}")

            for column_name in MONGODB_COLUMNS:
                if column_name not in article_df.columns:
                    article_df[column_name] = None
            article_df = article_df[MONGODB_COLUMNS]

            for row in article_df.to_dict(orient="records"):
                logging.info(f"{row}")
                collection.replace_one({"id": row.get("id")}, row, upsert=True)

        except json.decoder.JSONDecodeError:
            logging.info(f"Going to delete {blob} from Blob Storage..")
            blob_client.delete_blob(delete_snapshots="include")


class DAGFactory:
    """
    Class that provides useful method to build an Airflow DAG
    """

    @classmethod
    def create_dag(
        cls,
        dag_version,
        etl_conf,
        kw_default_args,
        max_active_tasks=2,
        catchup=False,
        max_active_runs=1,
    ):
        """Create a DAG for backtesting logic.

        Parameters
        ----------
        cls : Object
            Instance of DAGFactory class.
        dag_version : str
            DAG id.
        etl_conf : dict
            etl configurations for this combination of source and indication.
        kw_default_args : dict
            default args.
        catchup : bool
            Perform scheduler catchup (or only run latest)? Defaults to True.
        max_active_tasks : int
            the number of task instances allowed to run concurrently.
        max_active_runs : int
            maximum number of active runs for this DAG.
            The scheduler will not create new active DAG runs once this limit is hit.

        Returns
        -------
        dag : DAG object
            Dag that contains backtesting logic.

        """

        if kw_default_args is None:
            kw_default_args = {}

        dag_args = {
            **DEFAULT_ARGS_COMMONS,
            **kw_default_args,
            "start_date": datetime(2021, 12, 11),
        }

        dag_source_name = etl_conf["source_name"].lower().replace(" ", "_")
        dag_indication = etl_conf["indication"].lower().replace(" ", "_")

        with DAG(
            dag_id=f"{dag_source_name}__{dag_indication}__etl__{dag_version}",
            tags=["extraction", *etl_conf["tags"]],
            default_args=dag_args,
            schedule_interval="0 */2 * * *",
            max_active_tasks=max_active_tasks,
            catchup=catchup,
            max_active_runs=max_active_runs,
        ) as dag:

            start_task = DummyOperator(task_id="setup")

            extract_task = get_data_task.partial(
                task_id=f"get_news_articles",
                indication=etl_conf["indication"],
                therapeutic_area=etl_conf["therapeutic_area"],
                source_name=dag_source_name
            ).expand(keyword=etl_conf["input_data"])

            wait_extract_task = DummyOperator(
                task_id="wait_extract_task",
                trigger_rule="none_failed_or_skipped"
            )

            load_to_bs_task = load_data_to_blob_storage_task.partial(
                task_id=f"load_news_to_bs",
                trigger_rule="none_failed_or_skipped",
                indication=etl_conf["indication"],
                source_name=dag_source_name,
            ).expand(keyword=etl_conf["input_data"])

            wait_load_to_bs_task = DummyOperator(
                task_id="wait_load_to_bs",
                trigger_rule="none_failed_or_skipped"
            )

            load_to_mongodb_task = load_data_to_mongodb_task.partial(
                task_id=f"load_news_from_bs_to_mongodb",
                indication=etl_conf["indication"],
                source_name=dag_source_name,
                trigger_rule="none_failed_or_skipped"
            ).expand(keyword=etl_conf["input_data"])

            cleanup_tmp_files_task = PythonOperator(
                task_id="cleanup_tmp_files",
                python_callable=cleanup_csv_files,
                trigger_rule="none_failed_or_skipped"
            )

            end_task = DummyOperator(task_id="end", trigger_rule="all_success")

            start_task >> extract_task >> wait_extract_task >> load_to_bs_task >> wait_load_to_bs_task >> load_to_mongodb_task >> cleanup_tmp_files_task >> end_task  # pylint:disable=pointless-statement # noqa: E501

        return dag

    @classmethod
    def get_airflow_dag(
        cls,
        dag_version,
        etl_conf,
        kw_default_args=None,
    ):
        """Return a DAG according to a given configuration.

        Parameters
        ----------
        cls : Object
            Instance of DAGFactory class.
        dag_version : str
            DAG id.
        etl_conf : dict
            specific configurations for this combination of source and indication.
        kw_default_args : dict
            default args.

        Returns
        -------
        dag : DAG object
            Dag that runs backtesting logic.
        """
        dag = cls.create_dag(dag_version, etl_conf, kw_default_args)
        return dag
