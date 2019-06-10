FROM darthjee/circleci_ruby_250:0.2.3 as base
FROM darthjee/scripts:0.0.2 as scripts

######################################

FROM base as builder

ADD home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/* ./bundle_builder.sh

ENV HOME_DIR /home/circleci
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /home/app/bundle/gems/ /usr/local/bundle/gems/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/cache/ /usr/local/bundle/cache/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/specifications/ /usr/local/bundle/specifications/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/bin /usr/local/bundle/bin
COPY --chown=circleci:circleci --from=builder /home/app/bundle/extensions /usr/local/bundle/extensions

USER circleci
