FROM darthjee/circleci_rails_bower:0.4.0 as base
FROM darthjee/scripts:0.1.7 as scripts

######################################

FROM base as builder

COPY --chown=app:app home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

######################################
#FINAL BUILD
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app --from=builder /home/app/bower/ /home/app/.cache/bower/
