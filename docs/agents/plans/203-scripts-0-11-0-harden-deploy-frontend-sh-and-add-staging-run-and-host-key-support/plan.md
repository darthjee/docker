# Plan: scripts 0.11.0: harden deploy_frontend.sh and add staging, run and host-key support

Issue: [203-scripts-0-11-0-harden-deploy-frontend-sh-and-add-staging-run-and-host-key-support.md](../../issues/203-scripts-0-11-0-harden-deploy-frontend-sh-and-add-staging-run-and-host-key-support.md)

## Overview

Create `scripts/0.11.0` with a rewritten `home/sbin/deploy_frontend.sh` (fail fast, per-workflow
staging with `DEPLOY_PATH`, POSIX quoting, opt-in host-key checking, new `run` action,
`EXCLUDE_FROM`, `BUILD_COMMAND`, `KEEP_OLD`, first-deploy-safe `release`), its README, and a bash
test suite with stubbed `ssh`/`rsync`. The shared image-test harness is extended so a version can
ship its own test Dockerfile, which is what lets the alpine `scripts` image be tested at all.

## Agents involved

- [shell](shell.md) — `scripts/0.11.0/` (script, README, tests, test Dockerfile) and the `version` bump.
- [architect](architect.md) — `bin/image.sh` and `docker-compose.yml` (shared tooling, outside
  the shell agent's scope).

## Shared contracts

- **Per-version test Dockerfile:** an image version may provide `<image>/<version>/test/Dockerfile`.
  When it exists, `bin/image.sh test <image>` builds the test image with it instead of the root
  `Dockerfile.test`, with the repo root as build context and the same build args
  (`DOCKER_ID_USER`, `IMAGE`, `VERSION`, `USER_NAME`).
- **Test entry point:** the test image's default command is `/home/test/test.sh`. For an image
  with its own test Dockerfile, `bin/image.sh test` runs that default command (not `pwd`), and
  its exit status is the exit status of `bin/image.sh test`: non-zero when any test fails.
- `scripts/0.11.0/test/test.sh` must exit non-zero on any failing subtest (unlike the
  `|| exit 0` pattern in older images).
- Images without a per-version test Dockerfile behave exactly as today.
