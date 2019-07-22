FROM circleci/ruby:2.5.0 as base

USER root
RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter && chmod +x /usr/local/bin/cc-test-reporter
USER circleci

RUN mkdir /home/circleci/project/

WORKDIR /home/circleci/project/

FROM darthjee/scripts:0.0.2 as scripts
######################################

FROM base as builder

ADD home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/bundle_builder.sh ./bundle_builder.sh

ENV HOME_DIR /home/circleci
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE

FROM base

USER root

COPY --chown=circleci:circleci --from=builder /home/app/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/bin /usr/local/bundle/bin
COPY --chown=circleci:circleci --from=builder /home/app/bundle/extensions /usr/local/bundle/extensions

USER circleci
