FROM darthjee/scripts:0.1.7 as scripts
FROM darthjee/circleci_ruby_250:0.4.0 as base
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

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /usr/local/bundle/

COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_readme.sh /usr/local/sbin/

USER circleci
