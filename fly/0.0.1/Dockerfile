FROM alpine:3.9.4

RUN adduser -u 1000 fly; \
    mkdir -p /home/fly/workdir; \
    chown fly.fly -R /home/fly

COPY ./home/fly-5.5.6-linux-amd64.tgz /tmp
RUN tar -xzf /tmp/fly-5.5.6-linux-amd64.tgz -C /usr/local/bin

WORKDIR /home/fly/workdir

USER fly
