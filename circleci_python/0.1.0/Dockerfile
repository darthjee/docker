FROM cimg/python:3.12

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci:circleci -R /home/circleci/project

USER circleci
WORKDIR /home/circleci/project
