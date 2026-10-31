FROM darthjee/scripts:0.11.0 as scripts
FROM darthjee/taa:1.6.1 as base

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot && rm -rf /var/lib/apt/lists/*
USER app

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
