FROM darthjee/scripts:0.3.2 as scripts
######################################

FROM ruby:3.3.1 as base

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app.app -R /home/app

WORKDIR /home/app/app

RUN gem update --system; \
    gem install bundler:2.5.11 --default; \
    chown app.app /usr/local/bundle -R

USER app
######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/app
RUN bundle_builder.sh --without development test

#######################
#FINAL IMAGE

FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
