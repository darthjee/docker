FROM darthjee/circleci_taa:1.4.2 as base
FROM darthjee/scripts:0.4.3 as scripts

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

#######################
#FINAL BUILD
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot

COPY --chown=circleci:circleci --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=circleci:circleci --from=builder /home/circleci/.cache /home/circleci/.cache

USER circleci
