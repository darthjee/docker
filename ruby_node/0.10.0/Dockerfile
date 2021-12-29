FROM darthjee/ruby_250:0.8.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash ; \
    apt-get update && apt-get install -y netcat nodejs; \
    wget -qO- "https://github.com/dustinblackman/phantomized/releases/download/2.1.1/dockerized-phantomjs.tar.gz" | tar xz -C /; \
    npm install -g phantomjs; \
    apk del .build-deps

USER app
