FROM darthjee/ruby_240:0.2.3 as base

######################################

FROM base as builder

ADD home/* /home/app/app/

RUN bundle install --clean

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=app:app --from=builder /usr/local/bundle /usr/local/bundle

USER app
