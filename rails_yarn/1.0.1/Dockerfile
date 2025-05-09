FROM darthjee/scripts:0.4.3 as scripts
FROM darthjee/ruby_node:1.4.2 as base

USER root

RUN apt-get install telnet; \
    npm install yarn -g;

USER app

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

USER root
COPY --chown=app:app --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app --from=builder /home/app/node_modules/ /usr/lib/node_modules
