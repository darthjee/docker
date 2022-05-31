FROM darthjee/ruby_270:1.0.0 as base
FROM darthjee/scripts:0.2.0 as scripts
######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/app
RUN bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
