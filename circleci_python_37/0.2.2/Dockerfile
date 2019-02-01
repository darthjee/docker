FROM circleci/python:3.7.2

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci /home/circleci -R;

WORKDIR /home/circleci/project
RUN pip install pipenv

USER circleci
