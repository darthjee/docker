FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/circleci_ruby_3412:1.0.0 AS base
######################################

FROM base AS builder

COPY --chown=circleci:circleci home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR=/home/circleci
ENV BUNDLE_FOLDER=/home/circleci/.rubygems
RUN bundle_builder.sh

######################################
#FINAL IMAGE

FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
