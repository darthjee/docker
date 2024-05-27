FROM darthjee/circleci_ruby_331:1.0.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_17.x | /bin/bash; \
    apt-get update && apt-get install -y netcat nodejs

USER circleci
