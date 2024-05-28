FROM darthjee/production_ruby_331:1.0.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_20.x | /bin/bash ; \
    apt-get update && apt-get install -y nodejs ncat; \
    curl -L https://npmjs.org/install.sh | /bin/bash

USER app
