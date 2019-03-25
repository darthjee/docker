FROM darthjee/circleci_rails_bower:0.2.3 as base

######################################

FROM base as source

ADD home/* /home/circleci/project/

RUN bundle install --clean

RUN bower install

######################################
#FINAL BUILD
FROM base

USER root
COPY --chown=circleci:circleci --from=source /usr/local/bundle /usr/local/bundle
COPY --chown=circleci:circleci --from=source /home/circleci/.cache /home/circleci/.cache

USER circleci
