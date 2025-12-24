FROM darthjee/scripts:0.5.0 as scripts
FROM node:22 as base

USER root
RUN mkdir -p /home/node/app; \
    chown node /home/node/app -R

WORKDIR /home/node/app

######################################

FROM base as builder

ADD home/*  /home/node/app/

USER root
ENV HOME_DIR=/home/node
COPY --chown=node:node --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER node

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/node/yarn/new/ /usr/local/share/.cache/yarn/v6/
