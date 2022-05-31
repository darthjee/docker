FROM darthjee/circleci_ruby_270:1.0.0 as base
FROM darthjee/scripts:0.2.0 as scripts
######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/circleci
ENV BUNDLE_FOLDER /home/circleci/.rubygems
RUN bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
