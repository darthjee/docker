FROM node:10.7

RUN mkdir -p /home/node/app; \
    chown node /home/node -R;

WORKDIR /home/node/app

ADD node_home/*  /home/node/app/

RUN npm -g install $(sed -f packages_sed.sed package.json -n); \
    rm /home/node/app/* -f

USER node
