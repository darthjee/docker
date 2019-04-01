FROM circleci/ruby:2.4.1

USER root
RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/local/bin/cc-test-reporter && chmod +x /usr/local/bin/cc-test-reporter

USER circleci
RUN gem install bundler --version '1.17.3'

RUN mkdir /home/circleci/project/
WORKDIR /home/circleci/project/
