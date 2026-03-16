FROM darthjee/scripts:0.8.0 as scripts
FROM darthjee/circleci_ruby_331:1.1.1 as base

USER root

RUN curl -sL https://deb.nodesource.com/setup_22.x | /bin/bash ; \
    apt-get update && apt-get install -y nodejs ncat telnet; \
    curl -L https://npmjs.org/install.sh | /bin/bash; \
    npm install yarn -g

USER circleci

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
ENV BUNDLE_FOLDER /home/circleci/.rubygems
RUN /bin/bash bundle_builder.sh

USER root
COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
ENV APP_DIR /home/circleci/project
RUN /bin/bash yarn_builder.sh
USER app

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /usr/local/share/.cache/yarn/v6/

