FROM darthjee/scripts:0.1.1 as scripts
FROM darthjee/circleci_ruby_250:0.2.6 as base
######################################

FROM base as builder

ADD home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/circleci
RUN bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/bin /usr/local/bundle/bin
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/extensions /usr/local/bundle/extensions

COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_readme.sh /usr/local/sbin/

USER circleci
