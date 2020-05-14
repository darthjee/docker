FROM darthjee/circleci_rails_bower:0.5.0 as base
FROM darthjee/scripts:0.1.8 as scripts

######################################

FROM base as builder

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

######################################
#FINAL BUILD
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /usr/local/bundle/
COPY --chown=circleci:circleci --from=builder /home/circleci/bower/ /home/app/.cache/bower/
