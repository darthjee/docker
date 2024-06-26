FROM darthjee/scripts:0.4.2 as scripts
FROM circleci/node:12.22.7-bullseye-browsers-legacy as base

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci /home/circleci -R;

WORKDIR /home/circleci/project

######################################

FROM base as builder

ADD home/*  /home/circleci/project/

USER root
ENV MODULES_FOLDER=/usr/local/lib/node_modules
ENV HOME_DIR=/home/circleci
ENV APP_DIR=/home/circleci/project
COPY --chown=node:node --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER node

#######################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/node_modules/ /usr/local/lib/node_modules
