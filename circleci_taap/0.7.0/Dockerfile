FROM darthjee/circleci_taa:0.7.0. as base

######################################

FROM base as source

ADD home/* /home/circleci/project/

RUN bundle install --clean
RUN bower install

######################################
#FINAL BUILD
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot texlive-math-extra

USER root
COPY --chown=circleci:circleci --from=source /usr/local/bundle /usr/local/bundle
COPY --chown=circleci:circleci --from=source /home/circleci/.cache /home/circleci/.cache

USER circleci
