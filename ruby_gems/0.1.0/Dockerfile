FROM darthjee/ruby_250:0.2.3 as base

######################################

FROM base as builder

ADD home/* /home/app/app/

RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=app:app --from=builder /home/app/bundle/gems/* /usr/local/bundle/gems/
COPY --chown=app:app --from=builder /home/app/bundle/cache/* /usr/local/bundle/cache/
COPY --chown=app:app --from=builder /home/app/bundle/specifications/* /usr/local/bundle/specifications/

USER app
