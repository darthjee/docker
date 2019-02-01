FROM darthjee/rails_bower:0.2.2 as base

######################################

FROM base as builder

ADD taa_home/* /home/app/app/

RUN bundle install --clean

RUN bower install

#######################
#FINAL BUILD
FROM base

USER root
COPY --chown=app:app --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=app:app --from=builder /home/app/.cache /home/app/.cache

USER app
