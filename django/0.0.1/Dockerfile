FROM darthjee/scripts:0.4.3 as scripts
FROM python:3.12-slim-bullseye as base

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
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - ; \
    apt-get install -y nodejs; \
    npm install yarn -g; \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir poetry

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

USER root
COPY --chown=app:app --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER app

#######################
#FINAL IMAGE
FROM base

# RUN poetry install --no-root --no-interaction --no-ansi
COPY --chown=app:app --from=builder /home/app/node_modules/ /usr/lib/node_modules
COPY --chown=app:app home/* /home/app/app/

RUN yarn install; rm -rf node_modules
