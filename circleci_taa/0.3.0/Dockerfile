FROM darthjee/circleci_rails_bower:0.3.0 as base
FROM darthjee/scripts:0.1.3 as scripts

######################################

FROM base as builder

USER root

ADD home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

USER circleci

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
RUN /bin/bash bower_builder.sh

######################################
#FINAL BUILD
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/bin /usr/local/bundle/bin
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/extensions /usr/local/bundle/extensions

COPY --chown=circleci:circleci --from=builder /home/circleci/bower/registry/registry.bower.io/lookup/ /home/circleci/.cache/bower/registry/registry.bower.io/lookup/
COPY --chown=circleci:circleci --from=builder /home/circleci/bower/packages/ /home/circleci/.cache/bower/packages/

RUN chown circleci:circleci /home/circleci/ -R

USER circleci
