FROM darthjee/circleci_ruby_250:0.2.7

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash
RUN apt-get update && apt-get install -y netcat nodejs

USER circleci
