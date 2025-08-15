FROM darthjee/circleci_ruby_331:1.0.2 as base
FROM darthjee/scripts:0.4.3 as scripts
######################################

FROM base as builder

USER root
RUN apt-get update && apt-get install -y libsqlite3-dev
USER circleci

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER /home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
