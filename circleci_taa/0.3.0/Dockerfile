FROM darthjee/circleci_rails_bower:0.3.0 as base
FROM darthjee/scripts:0.1.2 as scripts

######################################

FROM base as source

ADD home/* /home/circleci/project/
ENV HOME_DIR /home/circleci

USER circleci

COPY --chown=criclecis:criclecis --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

COPY --chown=criclecis:criclecis --from=scripts /home/scripts/builder/bower_builder.sh /usr/local/sbin/bower_builder.sh
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

COPY --chown=criclecis:criclecis --from=builder /home/criclecis/bower/registry/registry.bower.io/lookup/ /home/criclecis/.cache/bower/registry/registry.bower.io/lookup/
COPY --chown=criclecis:criclecis --from=builder /home/criclecis/bower/packages/ /home/criclecis/.cache/bower/packages/

USER circleci
