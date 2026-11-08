# Rewrite the Dockerfiles
Rebase onto `ruby_node:2.0.0` and install only the delta. `rails_yarn/2.0.0/Dockerfile`:

```dockerfile
FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/ruby_node:2.0.0 AS base

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends telnet && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g yarn@1.22.22

USER app

######################################

FROM base AS builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR=/home/app

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
```

- `circleci_rails_yarn/2.0.0/Dockerfile`: `FROM darthjee/circleci_ruby_node:2.0.0 AS base`; same install `RUN`, followed (still `&&`-chained) by `mkdir -p /home/circleci/.cache/yarn && chown circleci:circleci /home/circleci/.cache -R`; `USER circleci`. Keep the existing builder/final stages (bundle first with `BUNDLE_FOLDER=/home/circleci/.rubygems`, then `yarn_builder.sh` as root with `APP_DIR=/home/circleci/project`; final copies to `/home/circleci/.rubygems/` and `/home/circleci/.cache/yarn/v6/`).
- `production_rails_yarn/2.0.0/Dockerfile`: `FROM darthjee/production_ruby_node:2.0.0 AS base`; same install `RUN`; keep `bundle config set without 'development test'`, the final `mkdir -p tmp/pids && chown app:app tmp/pids` (was `app.app`) and `ENV BUNDLE_WITHOUT=development:test`.
- Everywhere: uppercase `AS`, `ENV K=V`, `&&` chaining so any failure fails the build.

## Files to Change
- `rails_yarn/2.0.0/Dockerfile`, `circleci_rails_yarn/2.0.0/Dockerfile`, `production_rails_yarn/2.0.0/Dockerfile`
