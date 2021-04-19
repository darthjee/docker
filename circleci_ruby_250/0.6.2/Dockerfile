FROM darthjee/scripts:0.1.7 as scripts
######################################

FROM circleci/ruby:2.5.0 as base

USER root

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter && chmod +x /usr/local/bin/cc-test-reporter; \
    mkdir /home/circleci/project/; \
    chown circleci:circleci -R /home/circleci/project/

USER circleci

WORKDIR /home/circleci/project/

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/circleci
RUN bundle_builder.sh

#######################
#FINAL IMAGE

FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /usr/local/bundle/

COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/rubycritic.sh /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_specs /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_readme.sh /home/circleci/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/build_gem.sh /home/circleci/sbin/
