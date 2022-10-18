"""DAG HELPERS"""

from pharma_news.extract import (
    get_data_from_clinicaltrials,
    get_data_from_gnews,
    get_data_from_galerts,
)

from pharma_news.transform import (
    transform_clinicaltrials_articles,
    transform_gnews_articles,
    transform_galerts_articles,
)

PROCESS_NEWS_CRON = {
    "google_news": "0 */2 * * *",
    "clinical_trials": "0 */2 * * *",
    "google_alerts": "0 */2 * * *",
}

MAIL_RECIPIENTS = [
    "wais@datakimia.com",
    "david@datakimia.com",
    "juanm@datakimia.com",
    "tomas@datakimia.com",
]

# DEFAULT ARGS
DEFAULT_ARGS_COMMONS = {
    "owner": "atacana",
    # "retries": 5,
    # "retry_delay": timedelta(minutes=5),
    "email": MAIL_RECIPIENTS,
    "email_on_failure": True,
    "email_on_retry": False,
}

EXTRACTION_MAPPER = {
    "google_news": get_data_from_gnews,
    "clinical_trials": get_data_from_clinicaltrials,
    "google_alerts": get_data_from_galerts,
}

TRANSFORMATION_MAPPER = {
    "google_news": transform_gnews_articles,
    "clinical_trials": transform_clinicaltrials_articles,
    "google_alerts": transform_galerts_articles,
}
