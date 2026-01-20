FROM alpine:3.9.4 as base

RUN mkdir -p /home/scripts
RUN apk add --no-cache curl jq

COPY home /home/scripts

WORKDIR /home/scripts/
