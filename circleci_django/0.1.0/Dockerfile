FROM darthjee/scripts:0.9.0 as scripts
FROM cimg/python:3.12 as base

USER root

RUN apt-get update && apt-get install -y \
    pkg-config \
    iputils-ping \
    default-mysql-client; \
    rm -rf /var/lib/apt/lists/* ; \
    chown circleci:circleci -R /home/circleci/project/

USER circleci

WORKDIR /home/circleci/project/

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project
ENV HOME_DIR /home/circleci
ENV APP_DIR /home/circleci/project

USER circleci
COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/poetry_builder.sh /usr/local/sbin/poetry_builder.sh
RUN /bin/bash poetry_builder.sh -v

#######################
# FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/poetry/new/ /home/circleci/.cache/pypoetry/artifacts/
USER circleci


