FROM darthjee/scripts:0.1.8 as scripts
FROM darthjee/circleci_ruby_250:0.5.0 as base
######################################

FROM base as builder

ADD home/* /home/circleci/project/
RUN mkdir /home/circleci/sbin

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_readme.sh /home/circleci/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/build_gem.sh /home/circleci/sbin/

ENV HOME_DIR /home/circleci
RUN bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /usr/local/bundle/
COPY --chown=circleci:circleci --from=builder /home/circleci/sbin/ /usr/local/sbin/

USER circleci
