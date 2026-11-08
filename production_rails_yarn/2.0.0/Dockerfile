FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/production_ruby_node:2.0.0 AS base

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends telnet && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g yarn@1.22.22

USER app

######################################

FROM base AS builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR=/home/app

USER root
COPY --chown=app:app --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN bundle config set without 'development test'
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app --from=builder /home/app/yarn/new/ /usr/local/share/.cache/yarn/v6/

USER root
RUN mkdir -p tmp/pids && chown app:app tmp/pids
USER app

ENV BUNDLE_WITHOUT=development:test
