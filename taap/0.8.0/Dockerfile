FROM darthjee/taa:0.8.0 as base
FROM darthjee/scripts:0.1.8 as scripts

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/

ENV HOME_DIR /home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=app:app --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

#######################
#FINAL BUILD
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot texlive-math-extra

COPY --chown=app:app --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=app:app --from=builder /home/app/.cache /home/app/.cache

USER app
