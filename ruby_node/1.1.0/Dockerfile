FROM darthjee/ruby_270:1.1.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash ; \
    apt-get update && apt-get install -y netcat nodejs

USER app
