FROM darthjee/production_rails_bower:0.10.0 as base
FROM darthjee/scripts:0.1.9 as scripts

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/

ENV HOME_DIR /home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN bundle_builder.sh --without development test

COPY --chown=app:app --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

#######################
#FINAL BUILD
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app --from=builder /home/app/bower/ /home/app/.cache/bower/
