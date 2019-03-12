FROM darthjee/circleci_ruby_250:0.2.2 as base

######################################

FROM base as builder

ADD home/* /home/circleci/project/

RUN bundle install --clean

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /usr/local/bundle /usr/local/bundle

USER circleci
