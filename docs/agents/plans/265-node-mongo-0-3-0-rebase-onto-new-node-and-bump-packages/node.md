# Plan: node_mongo 0.3.0: rebase onto new node and bump packages

Issue: [265-node-mongo-0-3-0-rebase-onto-new-node-and-bump-packages.md](../../issues/265-node-mongo-0-3-0-rebase-onto-new-node-and-bump-packages.md)

## Overview
Create new `0.3.0` versions of `node_mongo` and `circleci_node_mongo`. Rebase them onto the `0.3.0` `node` / `circleci_node` images from #264. Point both at MongoDB's `9.0` apt series, and pin `mongosh` and the database tools to the same exact versions in both images.

## Context
- `node_mongo/0.2.3` is `FROM darthjee/node:0.2.4`. It uses series `8.0` and installs `mongodb-mongosh` (unpinned) from MongoDB's Debian repo. It installs `mongodb-database-tools` `100.20.0` from per-arch `.deb` downloads, because the Debian repo has no arm64 tools package.
- `circleci_node_mongo/0.2.3` is `FROM darthjee/circleci_node:0.2.4`. It uses the Ubuntu repo at series `8.0` and installs both packages unpinned.
- `node:0.3.0` is built on `node:22.23.4`, which is Debian bookworm. `circleci_node:0.3.0` is built on `cimg/node:22.23.4`, which is Ubuntu.
- Checked on 2026-11-08 against `repo.mongodb.org`:
  - The bookworm `9.0` repo has `mongodb-mongosh=2.14.1` for amd64 and arm64. It has `mongodb-database-tools=100.20.1` for amd64 only.
  - The Ubuntu noble and jammy `9.0` repos have both packages for amd64 and arm64.
  - The `100.20.1` tools downloads exist for `debian12-x86_64` and `ubuntu2204-arm64` (also `ubuntu2404`).
- Neither image has a `scripts` build stage or npm packages of its own, so the epic's `scripts:0.15.0` rule does not apply. The dependency-versions rule from `docs/agents/contributing.md` is met by rebasing onto `0.3.0`.

## Steps

- [01 — Init new versions](node/01-init-versions.md)
- [02 — node_mongo Dockerfile](node/02-node-mongo-dockerfile.md)
- [03 — circleci_node_mongo Dockerfile](node/03-circleci-node-mongo-dockerfile.md)
- [04 — READMEs, build and verify](node/04-readme-build-verify.md)

## CI Checks
- `node_mongo`: `bin/script.sh test node_mongo` (no `test/` folder, so it prints "no tests"; the build is the real check)
- `circleci_node_mongo`: `bin/script.sh test circleci_node_mongo` (same)
- CI release jobs `release-node_mongo` (requires `release-node`) and `release-circleci_node_mongo` (requires `release-circleci_node`) already exist; no `.circleci/config.yml` change.

## Notes
- **Hard dependency on #264.** `darthjee/node:0.3.0` and `darthjee/circleci_node:0.3.0` must be merged and released before this can build. If they are not on Docker Hub yet, build them locally first with `bin/image.sh build node` and `bin/image.sh build circleci_node`.
- Re-check the pinned versions at implementation time. If a newer `mongosh` 2.x or tools `100.x` is in the `9.0` repo for every target platform, use it and pin it identically in both images.
- Keep `ubuntu2204-arm64` for the bookworm arm64 tools `.deb`, not `ubuntu2404`. Bookworm's glibc (2.36) is older than what the 24.04 build needs.
