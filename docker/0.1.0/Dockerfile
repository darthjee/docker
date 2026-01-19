FROM darthjee/scripts:0.6.0 as scripts

#######################################
FROM docker:29.2.0-rc.1-cli-alpine3.23

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app.app -R /home/app
