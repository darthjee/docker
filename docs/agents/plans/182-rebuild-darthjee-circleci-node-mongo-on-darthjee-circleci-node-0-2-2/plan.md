# Plan: Rebuild darthjee/circleci_node_mongo on darthjee/circleci_node:0.2.2

Issue: [182-rebuild-darthjee-circleci-node-mongo-on-darthjee-circleci-node-0-2-2.md](../../issues/182-rebuild-darthjee-circleci-node-mongo-on-darthjee-circleci-node-0-2-2.md)

## Overview
Create version `0.2.2` of both `node_mongo` and `circleci_node_mongo` (via `bin/script.sh init node_mongo 0.2.2`), rebased on `darthjee/node:0.2.2` and `darthjee/circleci_node:0.2.2`. Replace the unavailable `mongodb-clients` apt package with MongoDB's `mongodb-mongosh` + `mongodb-database-tools`, keep both images multi-arch (amd64 + arm64), and refresh the READMEs. This also resolves #180.

See [node.md](node.md) for the full plan.

## Root files (architect)
- `README.md` — in the image list, change `node_mongo:0.0.6` → `node_mongo:0.2.2` and `circleci_node_mongo:0.0.6` → `circleci_node_mongo:0.2.2`. Leave other (already stale) entries alone.
- `version` is updated by `bin/script.sh init` itself (`node_mongo=0.2.2`, `circleci_node_mongo=0.2.2`); just verify it.
- No CircleCI change needed: `release-node_mongo` / `release-circleci_node_mongo` already exist, and `bin/image.sh push` always builds `linux/amd64,linux/arm64` with buildx.
- PR description should say `Closes #180` in addition to `Fixes #182`.
