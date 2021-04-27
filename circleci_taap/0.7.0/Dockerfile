FROM darthjee/taa:0.7.0. as base
FROM darthjee/scripts:0.1.8 as scripts

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/app/

ENV HOME_DIR /home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

#######################
#FINAL BUILD
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot texlive-math-extra

COPY --chown=circleci:circleci --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=circleci:circleci --from=builder /home/circleci/.cache /home/circleci/.cache

USER circleci
