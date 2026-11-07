FROM alpine:3.24.4 AS base

RUN mkdir -p /home/scripts
RUN apk add --no-cache bash curl jq

COPY home /home/scripts

WORKDIR /home/scripts/
