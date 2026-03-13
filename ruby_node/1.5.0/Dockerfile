FROM darthjee/ruby_331:1.1.1

USER root

RUN curl -sL https://deb.nodesource.com/setup_22.x | /bin/bash ; \
    apt-get update && apt-get install -y nodejs ncat; \
    curl -L https://npmjs.org/install.sh | /bin/bash

USER app
