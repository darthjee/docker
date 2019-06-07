FROM darthjee/circleci_ruby_250:0.2.3 as base

######################################

FROM base as builder

ADD home/* /home/circleci/project/

RUN bundle install --clean

#######################
#FINAL IMAGE
FROM base

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash
RUN apt-get update && apt-get install -y netcat nodejs

USER circleci
