# Issue: scripts 0.15.0: bump Alpine base and packages

## Description
Release a new `scripts` tool image version, `0.15.0`, on an up-to-date Alpine base. This is the first sub-issue of epic #256 (update packages and dependencies across images): every other image copies scripts from `darthjee/scripts` as a build stage, and their sub-issues move to `scripts:0.15.0`.

## Problem
`scripts/0.14.0` is built on `alpine:3.9.4`, which has been end-of-life for years. All of its scripts are `#!/bin/bash`, but the image does not ship bash: only `test/Dockerfile` installs it, so the image cannot run its own scripts directly.

## Expected Behavior
- `darthjee/scripts:0.15.0` is built on the latest stable Alpine, pinned to a full patch version, and includes `bash`, `curl` and `jq`.
- Its scripts are byte-identical to `0.14.0`, and the existing test suite passes.
- It builds on `linux/amd64` and `linux/arm64`.

## Solution
1. `bin/script.sh init scripts 0.15.0` to create `scripts/0.15.0` from `0.14.0`. Never patch `0.14.0` in place.
2. `Dockerfile`: `FROM alpine:3.x.y` (the latest stable release at implementation time, full patch pin) and `RUN apk add --no-cache bash curl jq`.
3. `test/Dockerfile`: drop the now-redundant `RUN apk add --no-cache bash`.
4. Keep `home/` (the `builder/` and `sbin/` scripts) unchanged. No script code changes are in scope.
5. Update `version` (`scripts=0.15.0`), `scripts/0.15.0/README.md` (per `docs/agents/image-readme.md`, including the new base and bash), and CI/compose/docs wherever the `scripts` version is referenced.
6. Verify with `bin/script.sh test scripts` and a multi-arch build (`linux/amd64`, `linux/arm64`).

Out of scope: moving other images to `scripts:0.15.0`, which their own #256 sub-issues handle. There are no counterpart images (`scripts` is a tool image).

## Benefits
- Removes a long-EOL base from the image every other image depends on.
- Makes the image self-sufficient for running its own bash scripts.
- Unblocks the remaining #256 sub-issues, which all move to `scripts:0.15.0`.
