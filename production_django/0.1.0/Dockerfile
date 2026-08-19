FROM darthjee/scripts:0.9.0 as scripts
FROM python:3.12-slim-bookworm as base

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app.app -R /home/app

WORKDIR /home/app/app/

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    iputils-ping \
    default-mysql-client \
    telnet curl ; \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir poetry==2.2.1

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

USER app
COPY --chown=app:app --from=scripts /home/scripts/builder/poetry_builder.sh /usr/local/sbin/poetry_builder.sh
RUN /bin/bash poetry_builder.sh --only main

#######################
# FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/poetry/new/ /home/app/.cache/pypoetry/artifacts/
USER app


