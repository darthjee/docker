FROM python:3.12.16-slim-bookworm

ARG PIPENV_VERSION=2026.10.6

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app:app -R /home/app

WORKDIR /home/app/app

RUN pip install --no-cache-dir pipenv==${PIPENV_VERSION}
USER app
