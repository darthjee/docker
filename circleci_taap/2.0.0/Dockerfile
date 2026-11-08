FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/circleci_taa:2.0.0 AS base

######################################

FROM base AS builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR=/home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER=/home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

######################################
#FINAL IMAGE
FROM base

USER root
RUN apt-get update && apt-get install -y --no-install-recommends gnuplot-nox && rm -rf /var/lib/apt/lists/*
USER circleci

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
