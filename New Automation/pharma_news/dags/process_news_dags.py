"""Contains DAG for news articles extraction from many sites/sources."""
import json

from pharma_news.constants import REDIS_LIST_NAME_CONF
from pharma_news.dags.process_news_dag_factory import DAGFactory
from pharma_news.db_helpers import get_redis_conn


r = get_redis_conn()

dag_version = "20220109"
source_names = ["google_news", "clinical_trials", "google_alerts"]
indications_keywords = r.lrange(REDIS_LIST_NAME_CONF, 0, -1)


for dag_conf in indications_keywords:

    dag_conf = json.loads(dag_conf)

    for source_name in source_names:

        dag_conf["tags"] = [dag_conf["therapeutic_area"]]
        dag_conf["source_name"] = source_name
        dag_conf["input_data"] = dag_conf[source_name]

        dag = DAGFactory().get_airflow_dag(
            dag_version=dag_version,
            etl_conf=dag_conf
        )

        globals()[f"{source_name}_{dag_conf['indication']}"] = dag
