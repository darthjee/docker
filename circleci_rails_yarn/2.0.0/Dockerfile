FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/circleci_ruby_node:2.0.0 AS base

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends telnet && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g yarn@1.22.22 && \
    mkdir -p /home/circleci/.cache/yarn && \
    chown circleci:circleci /home/circleci/.cache -R

USER circleci

######################################

FROM base AS builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR=/home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER=/home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

USER root
COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
ENV APP_DIR=/home/circleci/project
RUN /bin/bash yarn_builder.sh
USER circleci

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /home/circleci/.cache/yarn/v6/
