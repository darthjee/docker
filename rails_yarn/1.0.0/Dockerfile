FROM darthjee/scripts:0.4.0 as scripts
FROM darthjee/ruby_node:1.4.1 as base

USER root
RUN npm install yarn -g; \
    mkdir /home/app/.cache; \
    chown app.app /home/app/.cache -R
USER app

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
