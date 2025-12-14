FROM darthjee/scripts:0.5.0 as scripts
FROM cimg/python:3.12 as base

USER root

RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    pkg-config \
    iputils-ping \
    default-mysql-client \
    nodejs; \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - ; \
    apt-get install -y nodejs; \
    npm install yarn -g; \
    rm -rf /var/lib/apt/lists/* ; \
    chown circleci:circleci -R /home/circleci/project/

USER circleci

WORKDIR /home/circleci/project/

######################################

FROM base as builder

COPY --chown=app:app home/* /home/circleci/project
ENV HOME_DIR /home/circleci

USER root
COPY --chown=app:app --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh

USER app
COPY --chown=app:app --from=scripts /home/scripts/builder/poetry_builder.sh /usr/local/sbin/poetry_builder.sh
RUN /bin/bash poetry_builder.sh

#######################
# FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/circleci/yarn/new/ /usr/local/share/.cache/yarn/v6/
COPY --chown=app:app --from=builder /home/circleci/poetry/new/ /home/circleci/.cache/pypoetry/artifacts/
USER app


