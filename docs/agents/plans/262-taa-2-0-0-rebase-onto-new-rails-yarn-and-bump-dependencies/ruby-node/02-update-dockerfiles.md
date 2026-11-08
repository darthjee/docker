# Update the Dockerfiles
Keep the existing builder/final stage structure, and apply the #261 hardening:

- `FROM darthjee/scripts:0.15.0 AS scripts` and `FROM darthjee/{,circleci_,production_}rails_yarn:2.0.0 AS base` (uppercase `AS` on every stage, including `FROM base AS builder`).
- `ENV HOME_DIR=/home/app` (the `ENV K=V` form) in dev and production.
- circleci: chain the yarn-cache seeding into one step, keeping the comment:
  ```dockerfile
  RUN mkdir -p /usr/local/share/.cache/yarn/v6 && \
      cp -R /home/circleci/.cache/yarn/v6/. /usr/local/share/.cache/yarn/v6/
  ```
- production: `production_rails_yarn:2.0.0` sets `ENV BUNDLE_WITHOUT=development:test` in its final stage, so it is inherited by `taa`'s builder. Check with `docker run --rm darthjee/production_rails_yarn:2.0.0 bundle config get without` (or `env | grep BUNDLE_WITHOUT`); if development/test are excluded, drop `RUN bundle config set without 'development test'`, otherwise keep it.

## Files to Change
- `taa/2.0.0/Dockerfile`
- `circleci_taa/2.0.0/Dockerfile`
- `production_taa/2.0.0/Dockerfile`
