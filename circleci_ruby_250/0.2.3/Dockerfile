FROM circleci/ruby:2.5.0 as base

RUN mkdir /home/circleci/project/
WORKDIR /home/circleci/project/

######################################

FROM base as builder

ADD home/* /home/circleci/project/

RUN bundle install --clean

#######################
#FINAL IMAGE

FROM base

USER root

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter && chmod +x /usr/local/bin/cc-test-reporter
COPY --chown=circleci:circleci --from=builder /usr/local/bundle /usr/local/bundle

USER circleci
