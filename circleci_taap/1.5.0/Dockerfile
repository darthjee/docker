FROM darthjee/scripts:0.11.0 as scripts
FROM darthjee/circleci_taa:1.6.0 as base

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR=/home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER=/home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

######################################
#FINAL IMAGE
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot && rm -rf /var/lib/apt/lists/*
USER circleci

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
