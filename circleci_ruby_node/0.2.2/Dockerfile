FROM darthjee/circleci_ruby_250:0.1.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash
RUN apt-get update && apt-get install -y netcat nodejs

USER circleci

RUN mkdir /home/circleci/project
WORKDIR /home/circleci/project

RUN gem install bundler
