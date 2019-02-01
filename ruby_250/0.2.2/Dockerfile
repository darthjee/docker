FROM ruby:2.5.0

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app.app -R /home/app

WORKDIR /home/app/app

RUN gem install bundler
RUN chown app.app /usr/local/bundle -R
USER app
