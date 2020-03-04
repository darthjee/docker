FROM darthjee/ruby_node:0.3.1 as base
FROM darthjee/scripts:0.1.3 as scripts

######################################

FROM base as builder

USER root
RUN npm install bower -g
USER app

ADD home/* /home/app/app/
ENV HOME_DIR /home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=app:app --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

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

COPY --chown=app:app --from=builder /home/app/bower/registry/registry.bower.io/lookup/ /home/app/.cache/bower/registry/registry.bower.io/lookup/
COPY --chown=app:app --from=builder /home/app/bower/packages/ /home/app/.cache/bower/packages/

RUN chown -R app.app /home/app/.cache

USER app
