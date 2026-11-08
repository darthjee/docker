FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/production_taa:2.0.0 AS base

######################################

FROM base AS builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR=/home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root
RUN apt-get update && apt-get install -y --no-install-recommends gnuplot-nox && rm -rf /var/lib/apt/lists/*
USER app

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
