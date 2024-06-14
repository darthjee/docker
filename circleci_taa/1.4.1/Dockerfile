FROM darthjee/scripts:0.4.1 as scripts
FROM darthjee/circleci_rails_yarn:1.0.0 as base

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER /home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

USER root
COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER app

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
COPY --chown=circleci:circleci --from=builder /home/circleci/node_modules/ /usr/lib/node_modules
