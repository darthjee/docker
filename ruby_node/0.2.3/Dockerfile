FROM darthjee/ruby_250:0.2.3 as base


######################################

from base as builder

ADD home/* /home/app/app/

RUN bundle install --clean

#######################
#FINAL IMAGE

FROM base

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash
RUN apt-get update && apt-get install -y netcat nodejs
COPY --chown=app:app --from=builder /usr/local/bundle /usr/local/bundle

USER app
