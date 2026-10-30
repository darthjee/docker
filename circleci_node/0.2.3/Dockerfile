FROM darthjee/scripts:0.11.0 as scripts
FROM cimg/node:22.14.0 as base

USER root

RUN mkdir -p /home/circleci/project /home/circleci/.cache/yarn; \
    chown circleci:circleci /home/circleci -R;

WORKDIR /home/circleci/project

USER circleci

######################################

FROM base as builder

USER root

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci
ENV APP_DIR /home/circleci/project

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /home/circleci/.cache/yarn/v6/
