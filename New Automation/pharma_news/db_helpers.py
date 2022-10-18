import logging
from pymongo import MongoClient

import redis

from pharma_news.cfg import REDIS_HOST, REDIS_PORT, MONGODB_CONN_STR


def get_redis_conn():
    """
    Return default Redis connection.
    Returns
    -------
    """
    try:
        r_conn = redis.Redis(
            host=REDIS_HOST,
            port=REDIS_PORT,
            decode_responses=True
        )
        return r_conn

    except Exception:
        raise Exception("Could not connect to Redis DB.")


def get_mongodb_conn():
    """
    Return default MongoDB connection.
    Returns
    -------
    """
    try:
        client = MongoClient(MONGODB_CONN_STR)
        logging.info("Connected successfully!!!")

        # TODO: parametrize environment dev/prod.
        return client["develop"]

    except Exception as err:
        raise Exception("Could not connect to MongoDB")

