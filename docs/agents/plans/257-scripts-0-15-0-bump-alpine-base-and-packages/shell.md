# Shell Plan: scripts 0.15.0: bump Alpine base and packages

Main plan: [plan.md](plan.md)

## Overview
Create `scripts/0.15.0` from `0.14.0`, move it from the EOL `alpine:3.9.4` to the latest stable Alpine pinned to `3.x.y`, add `bash` to the image, drop the now-redundant bash install from the test Dockerfile, and update the version file and README. Part of epic #256; it is the first sub-issue, and every other sub-issue moves to `scripts:0.15.0`.

## Context
- `scripts/0.14.0/Dockerfile`: `FROM alpine:3.9.4 as base`, `apk add --no-cache curl jq`, copies `home/` to `/home/scripts`.
- All scripts in `home/builder` and `home/sbin` are `#!/bin/bash` (except `check_specs`, Ruby). They run inside the consuming images (copied with `COPY --from=scripts`). The scripts image itself has no bash.
- `scripts/0.14.0/test/Dockerfile` installs bash (`RUN apk add --no-cache bash`) before running `test/test.sh` (subtests in `test/subtests/`).
- CI (`.circleci/config.yml`) releases `scripts` first (`release-scripts`). Every other release `requires` it, and the image version comes from the `version` file.

## Steps

- [01 — Initialise scripts 0.15.0](shell/01-init-version.md)
- [02 — Bump the Alpine base and add bash](shell/02-bump-base.md)
- [03 — Update the README](shell/03-update-readme.md)
- [04 — Build and test](shell/04-build-and-test.md)

## CI Checks
- `scripts`: `bin/script.sh test scripts` (CI job: `release-scripts` workflow / scripts test job)

## Notes
- Determine the latest stable Alpine `3.x.y` at implementation time (Docker Hub `alpine` tags) and confirm it publishes both `linux/amd64` and `linux/arm64`.
- Do not modify anything under `scripts/0.15.0/home/`; it must stay identical to `0.14.0`.
- Do not change other images' `FROM darthjee/scripts:...` lines; their own #256 sub-issues do that.
