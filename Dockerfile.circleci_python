FROM circleci/python:2.7.15

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci /home/circleci -R;

WORKDIR /home/circleci/project
RUN pip install pipenv

USER circleci
