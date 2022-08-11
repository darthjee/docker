FROM darthjee/scripts:0.2.1 as scripts
######################################

FROM ruby:2.7.0 as base

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app.app -R /home/app

WORKDIR /home/app/app

RUN gem update --system; \
    gem install bundler:2.3.15 --default; \
    chown app.app /usr/local/bundle -R

USER app
######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR /home/app
RUN bundle_builder.sh

#######################
#FINAL IMAGE

FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/

COPY --chown=app:app --from=scripts /home/scripts/sbin/rubycritic.sh /usr/local/sbin/
COPY --chown=app:app --from=scripts /home/scripts/sbin/check_gems.sh /usr/local/sbin/
COPY --chown=app:app --from=scripts /home/scripts/sbin/check_specs /usr/local/sbin/
