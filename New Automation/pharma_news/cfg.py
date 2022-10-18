"""MODULE HELPERS FOR PHARMA_NEWS"""
from decouple import AutoConfig

from pharma_news.constants import PG_PORT_DEFAULT, REPO_ROOT

config = AutoConfig(search_path=REPO_ROOT)

# AZURE
AZURE_CONN_STR = config("AZURE_CONN_STR", default="azure", cast=str)

# MONGODB
MONGODB_CONN_STR = config("MONGODB_CONN_STR", default="mongodb", cast=str)
MONGODB_COLLECTION_NAME = config("MONGODB_COLLECTION_NAME", cast=str)

# REDIS
REDIS_HOST = config("REDIS_HOST", default="redis", cast=str)
REDIS_PORT = config("REDIS_PORT", default=6379)
