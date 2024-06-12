FROM darthjee/scripts:0.4.1 as scripts
FROM darthjee/circleci_ruby_node:1.4.1 as base

USER root

RUN npm install yarn -g;

USER circleci

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

USER root
COPY --chown=app:app --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER app

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
COPY --chown=app:app --from=builder /home/circleci/node_modules/ /usr/lib/node_modules
