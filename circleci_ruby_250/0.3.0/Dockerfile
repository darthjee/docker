FROM darthjee/scripts:0.1.2 as scripts
######################################

FROM circleci/ruby:2.5.0 as base

USER root
RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter && chmod +x /usr/local/bin/cc-test-reporter
USER circleci

RUN mkdir /home/circleci/project/

WORKDIR /home/circleci/project/

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

COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/rubycritic.sh /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_specs /usr/local/sbin/

USER circleci
