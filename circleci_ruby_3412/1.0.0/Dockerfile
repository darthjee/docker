FROM darthjee/scripts:0.15.0 AS scripts
######################################

FROM cimg/ruby:3.4.12 AS base

USER root

RUN gem install bundler:4.0.24; \
    chown circleci:circleci /home/circleci/.rubygems/ -R ; \
    chown circleci:circleci -R /home/circleci/project/

USER circleci

WORKDIR /home/circleci/project/

######################################

FROM base AS builder

COPY --chown=circleci:circleci home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR=/home/circleci
ENV BUNDLE_FOLDER=/home/circleci/.rubygems
RUN bundle_builder.sh

#######################
#FINAL IMAGE

FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/

COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/rubycritic.sh /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_specs /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/check_readme.sh /usr/local/sbin/
COPY --chown=circleci:circleci --from=scripts /home/scripts/sbin/build_gem.sh /usr/local/sbin/
