FROM darthjee/ruby_331:1.0.0

USER root

RUN curl --connect-timeout=5 -sL https://deb.nodesource.com/setup_20.x | /bin/bash ; \
    apt-get update && apt-get install -y nodejs ncat

USER app
