# Issue: Run darthjee/circleci_node as the circleci user

## Description

The final stage of `circleci_node/0.2.2/Dockerfile` runs as `root`: the `base` stage sets `USER root` and never switches back, so the published `darthjee/circleci_node` image runs as `root` instead of the `circleci` user that `cimg/node` uses by default. The builder stage also copies `yarn_builder.sh` with `--chown=node:node` and ends with `USER node`, although the project files are owned by `circleci`.

## Problem

- CI jobs and child images built on `darthjee/circleci_node` run as `root`, unlike the upstream `cimg/node` convention.
- Simply adding `USER circleci` would silently break the warm yarn cache: the cache is copied to `/usr/local/share/.cache/yarn/v6/`, which is yarn's cache dir **for root only**. Verified on `cimg/node:22.14.0`: as `circleci`, `yarn cache dir` prints `/home/circleci/.cache/yarn/v6`; as `root` it prints `/usr/local/share/.cache/yarn/v6`.
- Child image `circleci_node_mongo` (0.0.6) is not affected: it is built from the old `circleci_node:0.0.7` and already ends with `USER circleci`.

## Expected Behavior

- A new `circleci_node` version is created via `bin/script.sh init circleci_node` (`0.2.2` is not patched in place).
- The final image switches back to `USER circleci`, with `WORKDIR /home/circleci/project`.
- The warm yarn cache is copied to `/home/circleci/.cache/yarn/v6/` (yarn's default cache dir for `circleci`), owned by `circleci:circleci`, instead of `/usr/local/share/.cache/yarn/v6/`. No `YARN_CACHE_FOLDER` override.
- The builder stage uses `circleci:circleci` ownership for `yarn_builder.sh` instead of `node:node`, and drops the stray `USER node`.
- The new version gets a `test/` folder (following the `circleci_taa/1.5.0/test` layout: `test.sh` running `test/subtests/*.sh`) that checks:
  - `whoami` is `circleci`;
  - `yarn cache dir` resolves to `/home/circleci/.cache/yarn/v6`, and the pre-cached packages are present there.
- The new version's README states the runtime user (`circleci`) and the new cache location.

## Out of scope

- The same cache-location problem in `circleci_rails_yarn` / `circleci_taa` / `circleci_taap` is tracked separately in #217.
- `circleci_node_mongo` needs no change.
