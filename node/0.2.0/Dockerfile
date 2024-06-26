FROM darthjee/scripts:0.4.2 as scripts
FROM node:22 as base

USER root
RUN mkdir -p /home/node/app; \
    chown node /home/node/app -R

WORKDIR /home/node/app

######################################

FROM base as builder

ADD home/*  /home/node/app/

USER root
ENV MODULES_FOLDER=/usr/local/lib/node_modules
ENV HOME_DIR=/home/node
COPY --chown=node:node --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER node

#######################
#FINAL IMAGE
FROM base

COPY --chown=node:node --from=builder /home/node/node_modules/ /usr/local/lib/node_modules
