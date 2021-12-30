FROM darthjee/scripts:0.1.8 as scripts
FROM darthjee/ruby_node:0.10.0 as base

USER root
RUN npm install bower -g; \
    mkdir /home/app/.cache; \
    chown app.app /home/app/.cache -R
USER app

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=app:app --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app --from=builder /home/app/bower/ /home/app/.cache/bower/
