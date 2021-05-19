FROM alpine:3.13.5 as base

RUN mkdir -p /home/heroku; \
    chown 1000.1000 -R /home/heroku; \
    adduser -u 1000 -D -h /home/heroku heroku

RUN mkdir -p /home/heroku/.local/share/heroku \
    /home/heroku/.cache

RUN apk update; apk add curl bash nodejs npm git
RUN curl https://cli-assets.heroku.com/install.sh | sh
RUN heroku update

WORKDIR /home/heroku

COPY --chown=heroku:heroku home/ /home/heroku
USER heroku

ENTRYPOINT ["/home/heroku/scripts/entrypoint.sh"]
