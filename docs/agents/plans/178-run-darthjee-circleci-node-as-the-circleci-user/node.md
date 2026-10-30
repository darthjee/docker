# Plan: Run darthjee/circleci_node as the circleci user

Issue: [178-run-darthjee-circleci-node-as-the-circleci-user.md](../../issues/178-run-darthjee-circleci-node-as-the-circleci-user.md)

## Overview
Create `circleci_node/0.2.3`. Its final stage switches back to `USER circleci` and copies the warm yarn cache to `/home/circleci/.cache/yarn/v6/` instead of `/usr/local/share/.cache/yarn/v6/`. Clean up the builder's `node:node` ownership. Add a `test/` folder that checks the runtime user and the yarn cache, and update the README.

## Context
- `circleci_node/0.2.2/Dockerfile` sets `USER root` in `base` and never switches back, so the image runs as `root`.
- On `cimg/node:22.14.0`, `yarn cache dir` prints `/home/circleci/.cache/yarn/v6` as `circleci` and `/usr/local/share/.cache/yarn/v6` as `root` (checked during refinement). Switching the user without moving the cache would silently bypass the warm cache.
- `yarn_builder.sh` (scripts 0.10.0) hard-codes `GLOBAL_CACHE_PATH=/usr/local/share/.cache/yarn/v6` and works out the new packages from it. So the **builder stage must keep running yarn as root**. Only the final `COPY` destination changes.
- `yarn_builder.sh` defaults `APP_DIR` to `$HOME_DIR/app` (`/home/circleci/app`), which doesn't exist in this image. Today it only works because the failed `cd` leaves yarn running in the `WORKDIR`. Set `ENV APP_DIR /home/circleci/project` explicitly, as `circleci_taa/1.5.0` does.
- `circleci_node_mongo/0.0.6` builds from `circleci_node:0.0.7` and already ends with `USER circleci`: no change.
- The same cache-location bug in `circleci_rails_yarn`/`circleci_taa`/`circleci_taap` is out of scope (#217).

## Steps

- [01 — Init circleci_node 0.2.3](node/01-init-version.md)
- [02 — Rewrite the Dockerfile](node/02-dockerfile.md)
- [03 — Add tests](node/03-tests.md)
- [04 — Update the README](node/04-readme.md)

## CI Checks
CI (`.circleci/config.yml`) only releases images on tags. There are no PR checks for images. Verify locally:
- `bin/image.sh build circleci_node`
- `bin/image.sh test circleci_node`
- Sanity: `docker run --rm darthjee/circleci_node:0.2.3 bash -c 'whoami; yarn cache dir; yarn cache list | head'`

## Notes
- Use `bin/script.sh init circleci_node` (not `init node`): `init node` would also copy `node/0.2.2` to `node/0.2.3` and bump `node=` in `version`, and `node` is not changing.
- The scripts image stays at `darthjee/scripts:0.10.0`. Let `init` bump it if `version` says `scripts=0.11.0`, then check that `yarn_builder.sh` is unchanged there.
