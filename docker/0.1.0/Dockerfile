FROM darthjee/scripts:0.6.0 as scripts

#######################################
FROM docker:29.2.0-rc.1-alpine3.23

RUN adduser -D -u 1000 app \
    && mkdir -p /home/app/app \
    && chown app:app -R /home/app

RUN apk add --no-cache curl jq make

WORKDIR /home/app/app
USER app

COPY --chown=app:app --from=scripts /home/scripts/sbin/docker_hub.sh /usr/local/sbin/docker_hub.sh
