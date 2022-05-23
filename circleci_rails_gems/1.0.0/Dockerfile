FROM darthjee/circleci_ruby_270:1.0.0 as base
FROM darthjee/scripts:0.1.8 as scripts
######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/circleci
RUN bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /usr/local/bundle/
