FROM darthjee/taa:0.2.2 as base

######################################

FROM base as builder

ADD taap_home/* /home/app/app/

USER root
RUN bundle install --clean
USER app
RUN bower install

#FINAL BUILD
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot texlive-math-extra

COPY --chown=app:app --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=app:app --from=builder /home/app/.cache /home/app/.cache

USER app
