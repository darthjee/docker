FROM darthjee/circleci_rails_bower:0.2.5 as base
FROM darthjee/scripts:0.0.2 as scripts

######################################

FROM base as source

ADD home/* /home/circleci/project/
COPY --chown=circleci:circleci --from=scripts /home/scripts/bundle_builder.sh ./bundle_builder.sh
ENV HOME_DIR /home/circleci
RUN /bin/bash bundle_builder.sh

RUN bower install


######################################
#FINAL BUILD
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/bin /usr/local/bundle/bin
COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/extensions /usr/local/bundle/extensions

COPY --chown=circleci:circleci --from=builder /home/circleci/.cache /home/circleci/.cache

USER circleci
