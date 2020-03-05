FROM darthjee/scripts:0.1.6 as scripts
######################################

FROM ruby:2.5.0 as base

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app.app -R /home/app

WORKDIR /home/app/app

RUN gem install bundler
RUN chown app.app /usr/local/bundle -R

USER app
######################################

FROM base as builder

ADD home/* /home/app/app/

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/app
RUN bundle_builder.sh --without development test

#######################
#FINAL IMAGE

FROM base

USER root

COPY --chown=app:app --from=builder /home/app/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=app:app --from=builder /home/app/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=app:app --from=builder /home/app/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=app:app --from=builder /home/app/bundle/bin /usr/local/bundle/bin
COPY --chown=app:app --from=builder /home/app/bundle/extensions /usr/local/bundle/extensions

COPY --chown=app:app --from=scripts /home/scripts/sbin/rubycritic.sh /usr/local/sbin/
COPY --chown=app:app --from=scripts /home/scripts/sbin/check_specs /usr/local/sbin/

USER app
