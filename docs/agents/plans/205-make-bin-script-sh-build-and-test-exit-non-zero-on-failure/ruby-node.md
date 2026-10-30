# Ruby-Node Plan: Make bin/script.sh build and test exit non-zero on failure

Main plan: [plan.md](plan.md)

## Shared contracts

Relies on the architect's new `bin/image.sh test` (uses `<image>/<version>/test/Dockerfile` when present, otherwise `Dockerfile.test`; always runs `/home/test/test.sh` and returns its status) and on `test/` being excluded from the release skip check, so this is a same-version fix: no `bin/script.sh init`. Uses the canonical `test/test.sh` from [plan.md](plan.md#shared-contracts). Report already-broken images back to the architect; don't fix them here.

## Implementation Steps

### Step 1 — Replace test.sh and add test Dockerfiles for ruby_node
Overwrite `test/test.sh` with the canonical script in the 15 current version folders listed below (keep it executable).

The three `ruby_node` images have no `home/` folder, so the root `Dockerfile.test` (`COPY $IMAGE/$VERSION/home ./`) can't build for them. Add `test/Dockerfile` to each, modelled on `Dockerfile.test` without the `home` copy:

```dockerfile
ARG DOCKER_ID_USER
ARG IMAGE
ARG VERSION

FROM $DOCKER_ID_USER/$IMAGE:$VERSION

ARG USER_NAME
ARG IMAGE
ARG VERSION

COPY $IMAGE/$VERSION/test /home/test

USER root
RUN chown $USER_NAME:$USER_NAME /home/test -R
USER $USER_NAME
```

(`USER_NAME` is `app` or `circleci`, passed by `bin/image.sh`.)

### Step 2 — Run the tests
With `DOCKER_ID_USER=darthjee`, run `bin/script.sh test` for `ruby_node`, `taa`, `taap`, `rails_bower` and `rails_yarn` (build or pull the images first if needed). Confirm a failing subtest now makes the command exit non-zero (e.g. temporarily add a `subtests/zz_fail.sh` with `exit 1`, then remove it). For each image whose real subtests fail, report the image, the subtest and the output to the architect.

## Files to Change
- `ruby_node/1.5.0/test/test.sh`, `circleci_ruby_node/1.5.0/test/test.sh`, `production_ruby_node/1.5.0/test/test.sh`
- `ruby_node/1.5.0/test/Dockerfile`, `circleci_ruby_node/1.5.0/test/Dockerfile`, `production_ruby_node/1.5.0/test/Dockerfile` — new
- `taa/1.5.0/test/test.sh`, `circleci_taa/1.5.0/test/test.sh`, `production_taa/1.5.0/test/test.sh`
- `taap/1.4.2/test/test.sh`, `circleci_taap/1.4.2/test/test.sh`, `production_taap/1.4.2/test/test.sh`
- `rails_bower/1.4.0/test/test.sh`, `circleci_rails_bower/1.4.0/test/test.sh`, `production_rails_bower/1.4.0/test/test.sh`
- `rails_yarn/1.1.0/test/test.sh`, `circleci_rails_yarn/1.1.0/test/test.sh`, `production_rails_yarn/1.1.0/test/test.sh`

## Notes
- Don't touch subtests to make them pass. Broken subtests go into follow-up issues.
- #204 (rebuilding rails_bower on ruby_node 1.5.0) may create new rails_bower version folders. If it lands first, apply the change to the new current version instead.
