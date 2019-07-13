FROM darthjee/ruby_node:0.2.4 as base

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

COPY --chown=app:app --from=builder /home/app/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=app:app --from=builder /home/app/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=app:app --from=builder /home/app/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=app:app --from=builder /home/app/bundle/bin /usr/local/bundle/bin
COPY --chown=app:app --from=builder /home/app/bundle/extensions /usr/local/bundle/extensions

COPY --chown=app:app --from=builder /home/app/.cache /home/app/.cache

USER app
