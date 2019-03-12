FROM darthjee/circleci_ruby_250:0.2.2 as base

######################################

FROM darthjee/ruby_gems:0.0.1 as builder

#######################
#FINAL IMAGE
FROM base

USER root

COPY --chown=circleci:circleci --from=builder /usr/local/bundle /usr/local/bundle

USER circleci
