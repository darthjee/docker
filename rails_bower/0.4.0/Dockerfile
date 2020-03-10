FROM darthjee/scripts:0.1.7 as scripts
FROM darthjee/ruby_node:0.4.0 as base

USER root
RUN npm install bower -g

######################################

FROM base as builder

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

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app --from=builder /home/app/bower/ /home/app/.cache/bower/

USER app
