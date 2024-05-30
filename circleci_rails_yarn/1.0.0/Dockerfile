FROM darthjee/scripts:0.4.0 as scripts
FROM darthjee/circleci_ruby_node:1.4.1 as base

USER root
RUN apt-get install telnet
RUN npm install yarn -g; \
    mkdir /home/circleci/.cache; \
    chown circleci.circleci /home/circleci/.cache -R

USER circleci

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER /home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
