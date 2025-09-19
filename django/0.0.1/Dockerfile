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

COPY --chown=app:app home/* /home/app/app/

USER app
RUN poetry install --no-root --no-interaction --no-ansi
RUN yarn install

CMD ["bin/server.sh"]
