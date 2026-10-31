FROM darthjee/scripts:0.8.0 as scripts
FROM darthjee/ruby_331:1.1.1 as base

USER root

RUN curl -sL https://deb.nodesource.com/setup_22.x | /bin/bash ; \
    apt-get update && apt-get install -y nodejs ncat telnet; \
    curl -L https://npmjs.org/install.sh | /bin/bash; \
    npm install yarn -g;

USER app

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

USER root
COPY --chown=app:app --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh
USER app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app --from=builder /home/app/yarn/new/ /usr/local/share/.cache/yarn/v6/
