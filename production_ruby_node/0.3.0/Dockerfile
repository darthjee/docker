FROM darthjee/production_ruby_250:0.3.0

USER root

RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash
RUN apt-get update && apt-get install -y netcat nodejs

USER app
