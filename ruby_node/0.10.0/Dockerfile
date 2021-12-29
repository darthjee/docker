FROM darthjee/ruby_270:0.1.0

ENV PHANTOM_JS_VERSION ${PHANTOM_JS_VERSION:-2.1.1-linux-x86_64}

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash \
    && apt-get update \
    && apt-get install -y netcat nodejs ca-certificates curl bzip2 libfontconfig \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /tmp/phantomjs \
    && curl -Ls https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOM_JS_VERSION}.tar.bz2 \
      | tar -xj --strip-components=1 -C /tmp/phantomjs \
    && mv /tmp/phantomjs/bin/phantomjs /usr/local/bin
USER app
