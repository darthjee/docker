FROM python:3.12-slim-bookworm

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app:app -R /home/app

WORKDIR /home/app/app

RUN pip install --no-cache-dir pipenv
USER app
