FROM darthjee/scripts:0.1.2 as scripts
FROM darthjee/ruby_250:0.2.7 as base
######################################

FROM base as builder

ADD home/* /home/app/app/

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/app
RUN bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=app:app --from=builder /home/app/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=app:app --from=builder /home/app/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=app:app --from=builder /home/app/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=app:app --from=builder /home/app/bundle/bin /usr/local/bundle/bin
COPY --chown=app:app --from=builder /home/app/bundle/extensions /usr/local/bundle/extensions

COPY --chown=app:app --from=scripts /home/scripts/sbin/check_readme.sh /usr/local/sbin/

USER app
