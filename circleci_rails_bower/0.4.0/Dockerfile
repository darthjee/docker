FROM darthjee/scripts:0.1.7 as scripts
FROM darthjee/circleci_ruby_node:0.4.0 as base

USER root
RUN npm install bower -g

######################################

FROM base as builder

ADD home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

USER circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

######################################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /usr/local/bundle/
COPY --chown=circleci:circleci --from=builder /home/circleci/bower/ /home/circleci/.cache/bower/

USER circleci
