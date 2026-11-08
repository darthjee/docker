# Issue: node_mongo 0.3.0: rebase onto new node and bump packages

## Description
`node_mongo` (`0.2.3`) and its counterpart `circleci_node_mongo` (`0.2.3`) are built on `node:0.2.4` / `circleci_node:0.2.4`. They add only `mongosh` and `mongodb-database-tools`, from MongoDB's 8.0 apt series.

Part of epic #256.

**Depends on issues:** #257, #264 (must be merged and released first).

## Problem
- Both images are built on the old `node` / `circleci_node` `0.2.4`, so they miss the Node 22.23.4 base and the npm bumps from #264.
- The MongoDB repo still points at the 8.0 series. The newest series is 9.0.
- The versions are not pinned the same way. `node_mongo` pins database-tools (`100.20.0`) and takes `mongosh` from apt. `circleci_node_mongo` takes both from apt. The dev and CI images can drift apart.

## Expected Behavior
- New version `0.3.0` of `node_mongo` and `circleci_node_mongo`. Each is built on the matching `0.3.0` image from #264.
- Both images use MongoDB apt series `9.0` and install exactly `mongodb-mongosh=2.14.1` and `mongodb-database-tools` `100.20.1`, set through Dockerfile `ARG`s.
- Both images build on `linux/amd64` and `linux/arm64`.

## Solution
1. Run `bin/script.sh init node_mongo 0.3.0` and `bin/script.sh init circleci_node_mongo 0.3.0`, then update `version`.
2. `node_mongo/0.3.0/Dockerfile`:
   - Use `FROM darthjee/node:0.3.0`. Its base is `node:22.23.4`, which is Debian bookworm.
   - Set `MONGODB_SERIES=9.0`, `MONGOSH_VERSION=2.14.1` and `MONGODB_TOOLS_VERSION=100.20.1`.
   - Install `mongodb-mongosh=${MONGOSH_VERSION}` from the Debian bookworm repo.
   - Keep the per-arch tools `.deb` workaround: `debian12-x86_64` on amd64, `ubuntu2204-arm64` on arm64. MongoDB's bookworm repo still has no arm64 database-tools, and there is no debian12 arm64 `.deb`. Keep `ubuntu2204`, not `ubuntu2404`: the 24.04 build needs a newer glibc than bookworm ships.
3. `circleci_node_mongo/0.3.0/Dockerfile`:
   - Use `FROM darthjee/circleci_node:0.3.0`.
   - Use the Ubuntu repo at series `9.0`. It ships both packages for amd64 and arm64.
   - Install exactly `mongodb-mongosh=${MONGOSH_VERSION}` and `mongodb-database-tools=${MONGODB_TOOLS_VERSION}`, with the same `ARG` values as `node_mongo`.
4. This image has no `scripts` build stage, so the `scripts:0.15.0` rule does not apply. No npm packages are added on top of `node`, so the dependency-versions rule only means rebasing onto `0.3.0`.
5. Update both READMEs per `docs/agents/image-readme.md`.
6. Build both images on `linux/amd64` and `linux/arm64`, and run `bin/script.sh test` for both. Neither image has a `test/` folder today, so the build is the main check.
7. Check that `mongosh --version` and `mongodump --version` work in both images.

## Benefits
- The Mongo images follow the refreshed `node` 0.3.0 base.
- MongoDB tooling is current and identical in the dev and CI images, so builds are reproducible.
