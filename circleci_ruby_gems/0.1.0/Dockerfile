FROM darthjee/circleci_ruby_250:0.2.3 as base
FROM darthjee/scripts:0.0.1 as scripts

######################################

FROM base as builder

ADD home/* /home/circleci/project/

COPY --chown=app:app --from=scripts /home/scripts/* ./bundle_builder.sh

ENV HOME_DIR /home/circleci
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /home/app/bundle/gems/* /usr/local/bundle/gems/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/cache/* /usr/local/bundle/cache/
COPY --chown=circleci:circleci --from=builder /home/app/bundle/specifications/* /usr/local/bundle/specifications/

USER circleci
