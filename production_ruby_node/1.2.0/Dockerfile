FROM darthjee/production_ruby_270:1.2.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_18.x | /bin/bash; \
    apt-get update && apt-get install -y netcat nodejs

USER app
