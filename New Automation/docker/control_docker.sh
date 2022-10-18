#!/usr/bin/env bash

# Read env vars
parent_dir="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
if [ -f "$parent_dir/.env"  ]; then
    set -a
    # shellcheck disable=SC1091
    source "$parent_dir/.env"
    set +a
else
    echo ".env file is not in project root"
    exit 1
fi

if [[ -n "$2" ]]; then
    artifact="$2"
fi

# Obtain token for Jupyter Notebook service
function jupyter_token {
    echo 'Your TOKEN for Jupyter Notebook is:'
    SERVER=$(docker exec -it "$COMPOSE_PROJECT_NAME"_pharma_news_1 poetry run jupyter lab list)
    echo "${SERVER}" | grep '/notebook' | sed -E 's/^.*=([a-z0-9]+).*$/\1/'
}

function pg_connect {
    docker exec -it "$COMPOSE_PROJECT_NAME"-postgres-db-1 bash -c 'psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
}

# Execution of webserver container.
function exec_base {
    docker container exec -ti "$COMPOSE_PROJECT_NAME"-airflow-webserver-1 /bin/bash
}

# Check users list of Airflow
function airflow_ls {
    echo 'Checking users list of Airflow..'
    docker exec -it "$COMPOSE_PROJECT_NAME"-airflow-webserver-1 poetry run airflow users list
}

case "$1" in
    jupyter_token)
        jupyter_token
        ;;
    pg_connect)
        pg_connect
        ;;
    exec_base)
        exec_base
        ;;
    airflow_ls)
        airflow_ls
        ;;
    airflow_get_fernet_key)
        airflow_get_fernet_key
        ;;
    *)
        printf "ERROR: Missing command. Available commands: \n jupyter_token, pg_connect, exec_base, airflow_ls \n"
        exit 1
        ;;
esac
