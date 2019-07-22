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

RUN bundle install --clean

#######################
#FINAL IMAGE

FROM base

USER root

COPY --chown=app:app --from=builder /usr/local/bundle /usr/local/bundle

USER app
