FROM cimg/python:3.12.16

ARG PIPENV_VERSION=2026.10.6

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci:circleci -R /home/circleci/project

USER circleci
RUN pip install --no-cache-dir pipenv==${PIPENV_VERSION}
WORKDIR /home/circleci/project
