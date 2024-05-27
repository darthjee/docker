FROM darthjee/circleci_ruby_270:1.4.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_17.x | /bin/bash; \
    apt-get update && apt-get install -y netcat nodejs

USER circleci
