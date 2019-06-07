FROM darthjee/circleci_ruby_node:0.2.3 as base

######################################

FROM base as source

USER root
RUN npm install bower -g

ADD home/* /home/circleci/project/

RUN bundle install --clean

USER circleci
RUN bower install

######################################
#FINAL IMAGE
FROM base

USER root
RUN npm install bower -g

COPY --chown=circleci:circleci --from=source /usr/local/bundle /usr/local/bundle
COPY --chown=circleci:circleci --from=source /home/circleci/.cache /home/circleci/.cache

USER circleci
