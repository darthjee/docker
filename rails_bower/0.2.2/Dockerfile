FROM darthjee/ruby_node:0.2.2 as base

######################################

FROM base as builder

USER root
RUN npm install bower -g

ADD home/* /home/app/app/

RUN bundle install --clean

USER app
RUN bower install

#######################
#FINAL IMAGE
FROM base

USER root
RUN npm install bower -g

COPY --chown=app:app --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=app:app --from=builder /home/app/.cache /home/app/.cache

USER app
