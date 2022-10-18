FROM python:3.8

RUN apt-get update && apt-get install -y apt-utils build-essential unzip python-dev libaio-dev locales

ENV PATH="/root/.local/bin:$PATH"

# Setup pipx and poetry
RUN pip install pipx
RUN pipx install poetry
ENV PATH="/root/.local/pipx/venvs/poetry/bin/:$PATH"

COPY pyproject.toml /news-project/pyproject.toml
COPY poetry.lock /news-project/poetry.lock
WORKDIR /news-project
RUN poetry install --no-root
COPY . /news-project
RUN poetry install --no-interaction
