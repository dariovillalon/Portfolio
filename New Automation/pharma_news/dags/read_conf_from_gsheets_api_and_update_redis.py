import json
from datetime import datetime

from airflow.decorators import dag, task

from pharma_news.constants import REDIS_LIST_NAME_CONF
from pharma_news.dags.dags_helper import DEFAULT_ARGS_COMMONS
from pharma_news.db_helpers import get_redis_conn
from pharma_news.helpers import get_indication_keywords_conf


@dag(
    schedule_interval="*/5 * * * *",
    start_date=datetime(2022, 8, 29),
    catchup=False,
    default_args={
        **DEFAULT_ARGS_COMMONS
    },
    tags=["Configuration"])
def read_conf_from_gsheets_and_update_redis():

    @task()
    def read_from_gsheets_api():
        """
        ### Read File Conf.
        Read Pipeline Configuration from gsheets API.
        """
        return get_indication_keywords_conf()

    @task()
    def update_redis_instance(conf_data: list):
        """
        Update redis conf list.
        """
        r = get_redis_conn()

        r.delete(REDIS_LIST_NAME_CONF)

        for c in conf_data:
            r.lpush(REDIS_LIST_NAME_CONF, json.dumps(c))

    # Call the task functions to instantiate them and infer dependencies
    conf_data = read_from_gsheets_api()
    update_redis_instance(conf_data)


# Call the dag function to register the DAG
read_conf_from_gsheets_and_update_redis = read_conf_from_gsheets_and_update_redis()
