FROM circleci/node:17

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci /home/circleci -R;

WORKDIR /home/circleci/project

ADD home/*  /home/circleci/project/

RUN npm -g install $(sed -f packages_sed.sed package.json -n); \
    rm /home/circleci/project/* -f

USER circleci
