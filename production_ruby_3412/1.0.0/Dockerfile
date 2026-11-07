FROM darthjee/scripts:0.15.0 AS scripts
######################################

FROM ruby:3.4.12 AS base

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app:app -R /home/app

WORKDIR /home/app/app

RUN gem update --system; \
    gem install bundler:4.0.24 --default; \
    chown app:app /usr/local/bundle -R

USER app
######################################

FROM base AS builder

COPY --chown=app:app home/* /home/app/app/

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR=/home/app
RUN bundle config set without 'development test'
RUN bundle_builder.sh

#######################
#FINAL IMAGE

FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
