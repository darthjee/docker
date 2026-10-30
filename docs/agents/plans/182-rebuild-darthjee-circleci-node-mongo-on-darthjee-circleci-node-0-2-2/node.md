# Plan: Rebuild darthjee/circleci_node_mongo on darthjee/circleci_node:0.2.2

Issue: [182-rebuild-darthjee-circleci-node-mongo-on-darthjee-circleci-node-0-2-2.md](../../issues/182-rebuild-darthjee-circleci-node-mongo-on-darthjee-circleci-node-0-2-2.md)

## Overview
Rebuild `node_mongo` and `circleci_node_mongo` as `0.2.2` on the current Node.js 22 bases, swapping `mongodb-clients` for MongoDB's `mongosh` and Database Tools, multi-arch (amd64 + arm64).

## Context
- `node_mongo/0.0.6` is `FROM darthjee/node:0.0.7`; `circleci_node_mongo/0.0.6` is `FROM darthjee/circleci_node:0.0.7`. Both just `apt-get install mongodb-clients` as root, then switch back to `node` / `circleci`.
- `darthjee/circleci_node:0.2.2` is on `cimg/node:22.14.0` (Ubuntu 22.04 jammy). Its final stage inherits `USER root` from its `base` stage.
- `darthjee/node:0.2.2` is on `node:22` (Debian; confirm the codename — bookworm or trixie — with `/etc/os-release`). Its final stage also inherits `USER root`.
- `mongodb-clients` is not packaged for either distro anymore.
- `bin/script.sh init node_mongo <v>` copies `node_mongo`, `circleci_node_mongo` (and `production_node_mongo` if it existed), updates `version` and rewrites `darthjee/*` `FROM` tags to the current versions in `version`.
- Decisions from the issue: version `0.2.2`; install `mongodb-mongosh` + `mongodb-database-tools`; final user `circleci` / `node`; publish amd64 + arm64.

## Steps

- [01 — Init the 0.2.2 version](node/01-init-version.md)
- [02 — Rebuild circleci_node_mongo Dockerfile](node/02-circleci-node-mongo-dockerfile.md)
- [03 — Rebuild node_mongo Dockerfile](node/03-node-mongo-dockerfile.md)
- [04 — Update the image READMEs](node/04-update-readmes.md)
- [05 — Build and verify both architectures](node/05-build-and-verify.md)

## CI Checks
- `node_mongo`: `bin/script.sh pre_build node_mongo && bin/script.sh build node_mongo`
- `circleci_node_mongo`: `bin/script.sh pre_build circleci_node_mongo && bin/script.sh build circleci_node_mongo`
- Release (tag only): CircleCI jobs `release-node_mongo` and `release-circleci_node_mongo` (`bin/image.sh push <image>`, multi-arch buildx).

## Notes
- Risk: MongoDB's Debian apt repo may only ship amd64 packages. If arm64 isn't available for `node_mongo`'s Debian codename, use one of these fallbacks (in order of preference) so the image stays multi-arch:
  1. Download the per-arch `.deb` files for `mongosh` and `mongodb-database-tools` from MongoDB's download site, picking the file by `dpkg --print-architecture` / `TARGETARCH`.
  2. Use the matching Ubuntu repo packages. Both tools are self-contained binaries.
- Pin the MongoDB repo series (e.g. `8.0`), not a floating one, so rebuilds are reproducible.
- Use a `signed-by` keyring under `/usr/share/keyrings` (no deprecated `apt-key`), and clean `/var/lib/apt/lists/*` in the same layer.
- Don't touch `node_mongo/0.0.6` / `circleci_node_mongo/0.0.6`. Root `README.md` is handled by the architect (see [plan.md](plan.md)).
