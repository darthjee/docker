FROM darthjee/ruby_node:0.2.5 as base
FROM darthjee/scripts:0.1.2 as scripts

######################################

FROM base as builder

USER root
RUN npm install bower -g
USER app

ADD home/* /home/app/app/
COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV HOME_DIR /home/app
RUN /bin/bash bundle_builder.sh

RUN bower install

#######################
#FINAL IMAGE
FROM base

USER root
RUN npm install bower -g

COPY --chown=app:app --from=builder /home/app/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=app:app --from=builder /home/app/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=app:app --from=builder /home/app/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=app:app --from=builder /home/app/bundle/bin /usr/local/bundle/bin
COPY --chown=app:app --from=builder /home/app/bundle/extensions /usr/local/bundle/extensions

COPY --chown=app:app --from=builder /home/app/.cache /home/app/.cache

USER app
