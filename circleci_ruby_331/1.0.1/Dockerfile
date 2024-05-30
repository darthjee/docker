FROM darthjee/scripts:0.4.0 as scripts
######################################

FROM cimg/ruby:3.3.1 as base

USER root

RUN gem install bundler:2.5.11; \
    chown circleci.circleci /home/circleci/.rubygems/ -R ; \
    curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter && chmod +x /usr/local/bin/cc-test-reporter; \
    chown circleci:circleci -R /home/circleci/project/

USER circleci

WORKDIR /home/circleci/project/

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

COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/rubycritic.sh /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_specs /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_readme.sh /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/build_gem.sh /usr/local/sbin/
