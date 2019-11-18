FROM alpine:3.9.4

RUN adduser -u 1000 fly; \
    mkdir -p /home/fly/workdir; \
    chown fly.fly -R /home/fly

RUN wget -O /tmp/fly-5.5.6-linux-amd64.tgz https://github.com/concourse/concourse/releases/download/v5.5.6/fly-5.5.6-linux-amd64.tgz; \
    tar -xzf /tmp/fly-5.5.6-linux-amd64.tgz -C /usr/local/bin; \
    rm -f /tmp/fly-5.5.6-linux-amd64.tgz

WORKDIR /home/fly/workdir

RUN apk update; apk upgrade; apk add bash

USER fly
