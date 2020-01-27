FROM alpine:3.9.4

RUN adduser -u 1000 fly; \
    mkdir -p /home/fly/workdir; \
    chown fly.fly -R /home/fly

RUN wget -O /usr/local/bin/fly https://github.com/concourse/concourse/releases/download/v3.14.1/fly_linux_amd64
RUN chmod 755  /usr/local/bin/fly

WORKDIR /home/fly/workdir

RUN apk update; apk upgrade; apk add bash

USER fly
