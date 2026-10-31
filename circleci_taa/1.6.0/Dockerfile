FROM darthjee/scripts:0.11.0 as scripts
FROM darthjee/circleci_rails_yarn:1.2.0 as base

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR=/home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER=/home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

USER root
COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
ENV APP_DIR=/home/circleci/project
# yarn_builder.sh dedupes against root's cache; seed it with the inherited
# circleci cache so only packages new to this image end up in yarn/new/
RUN mkdir -p /usr/local/share/.cache/yarn/v6; \
    cp -R /home/circleci/.cache/yarn/v6/. /usr/local/share/.cache/yarn/v6/
RUN /bin/bash yarn_builder.sh
USER circleci

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /home/circleci/.cache/yarn/v6/
