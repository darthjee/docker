# Issue: Warm yarn cache unused in circleci_rails_yarn/taa/taap (wrong cache dir for circleci user)

## Description

`darthjee/circleci_rails_yarn:1.1.0` and the images built on it (`darthjee/circleci_taa:1.5.0`, `darthjee/circleci_taap:1.5.0`) run as `USER circleci`, but copy their warm yarn cache to `/usr/local/share/.cache/yarn/v6/`. Yarn uses that path only for `root`.

Spotted while refining #178, which fixed the same problem for `circleci_node`.

## Problem

Checked in the published `darthjee/circleci_rails_yarn:1.1.0` image: as `circleci`, `yarn cache dir` prints `/home/circleci/.cache/yarn/v6`, and that directory is empty. The pre-cached packages in `/usr/local/share/.cache/yarn/v6/` are never used, so `yarn install` downloads everything.

- `circleci_rails_yarn/1.1.0/Dockerfile` and `circleci_taa/1.5.0/Dockerfile` both copy `/home/circleci/yarn/new/` to `/usr/local/share/.cache/yarn/v6/`.
- `circleci_taap/1.5.0` has no yarn step of its own. It inherits the cache from `circleci_taa`, and its README states the wrong location.
- The `circleci_rails_yarn` README says the image is built on `darthjee/circleci_ruby_node`, but the Dockerfile uses `darthjee/circleci_ruby_331`.

## Expected Behavior

The current versions, created by #210 and not yet published on Docker Hub, are fixed in place (no `bin/script.sh init`, `version` unchanged), each built on the previous fixed one:

- `circleci_rails_yarn/1.2.0` (on `darthjee/circleci_ruby_331:1.2.0` and `darthjee/scripts:0.11.0`): creates `/home/circleci/.cache/yarn` owned by `circleci` and copies the warm cache to `/home/circleci/.cache/yarn/v6/` with `--chown=circleci:circleci`. The README states the correct cache location.
- `circleci_taa/1.6.0` (on `circleci_rails_yarn:1.2.0` and `scripts:0.11.0`): copies its warm cache to `/home/circleci/.cache/yarn/v6/`.
- `circleci_taap/1.5.0`: rebuilt on `circleci_taa:1.6.0` and `scripts:0.11.0`. Its README states the correct inherited cache location.
- Verified in each built image: as `circleci`, `yarn cache dir` prints `/home/circleci/.cache/yarn/v6`, and that directory holds the pre-cached packages.

## Solution

Follow the `circleci_node` fix from #178 (`circleci_node/0.2.3/Dockerfile`): create and `chown` `/home/circleci/.cache/yarn` in the base stage, then `COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /home/circleci/.cache/yarn/v6/` in the final stage. Owner: `ruby-node` agent.

## Benefits

CI jobs that use these images get the warm yarn cache they are meant to have, so `yarn install` is faster and makes fewer network fetches.
