FROM darthjee/scripts:0.4.1 as scripts
FROM node:22 as base

USER root
RUN mkdir -p /home/app/app; \
    chown node /home/app -R; \
    rm /home/node/app/* -f

WORKDIR /home/app/app

######################################

FROM base as builder

ADD home/*  /home/app/app/

USER root
COPY --chown=node:node --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER node

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/node_modules/ /usr/lib/node_modules
