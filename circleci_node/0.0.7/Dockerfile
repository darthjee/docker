FROM circleci/node:10.7

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci /home/circleci -R;

WORKDIR /home/circleci/project

ADD node_home/*  /home/circleci/project/

RUN npm -g install $(sed -f packages_sed.sed package.json -n); \
    rm /home/circleci/project/* -f

USER circleci
