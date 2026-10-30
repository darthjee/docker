# Issue: Rebuild darthjee/circleci_node_mongo on darthjee/circleci_node:0.2.2

## Description
`circleci_node_mongo/0.0.6/Dockerfile` is built `FROM darthjee/circleci_node:0.0.7`, an old base on `circleci/node:10.7`: Node.js 10 (end of life since 2021) on CircleCI's deprecated legacy `circleci/*` image. Its counterpart `node_mongo/0.0.6/Dockerfile` (#180) has the same problem: it is built `FROM darthjee/node:0.0.7` (Node.js 10.7). Both installed their npm packages globally with `npm -g install`. The only published tags (`0.0.6`, `latest`) date from 2018 and are amd64-only.

Because `bin/script.sh init node_mongo` creates the new `node_mongo` **and** `circleci_node_mongo` versions together, this issue covers **both** images. The PR resolving it also closes #180.

Spawned from #159.

## Problem
- Both images are pinned to an end-of-life Node.js runtime. `circleci_node_mongo` also sits on a deprecated CircleCI base image.
- Both are amd64-only.
- The `mongodb-clients` apt package is gone from the current bases: `cimg/node:22.14.0` (behind `darthjee/circleci_node:0.2.2`) is Ubuntu 22.04, and `node:22` (behind `darthjee/node:0.2.2`) is Debian bookworm. The existing install layer can't be carried over as-is.

## Expected Behavior
- New version `0.2.2` of both images (same version as their new bases):
  - `darthjee/node_mongo:0.2.2` built `FROM darthjee/node:0.2.2`
  - `darthjee/circleci_node_mongo:0.2.2` built `FROM darthjee/circleci_node:0.2.2`
- Both ship `mongosh` and the MongoDB Database Tools (`mongodump`, `mongorestore`, `mongoimport`, ...), installed from MongoDB's own apt packages (`mongodb-mongosh`, `mongodb-database-tools`) in place of `mongodb-clients`.
- Final user: `circleci_node_mongo` switches back to `USER circleci` after the root install, even though `circleci_node:0.2.2` itself ends as `root`. `node_mongo` switches back to `USER node`, as before.
- Both are published for `linux/amd64` and `linux/arm64`, like their bases.
- READMEs updated:
  - `circleci_node_mongo` reuses the `darthjee/circleci_node` pre-cached package list and links to the rebuilt `darthjee/node_mongo`.
  - `node_mongo` reuses the `darthjee/node` pre-cached package list and links to `darthjee/circleci_node_mongo`.
  - Both list the new MongoDB tools.
- References to `0.0.6` in the root `README.md` image list are updated to `0.2.2`.

## Solution
- Run `bin/script.sh init node_mongo 0.2.2`, which copies `node_mongo/0.0.6` and `circleci_node_mongo/0.0.6` to `0.2.2`, bumps `version`, and rewrites the `darthjee/*` `FROM` tags.
- In each new Dockerfile, as `USER root`, replace `mongodb-clients` with MongoDB's apt repository (signed keyring) and install `mongodb-mongosh` and `mongodb-database-tools`. Then switch back to the image's non-root user (`circleci` / `node`).
- Risk to verify while planning: MongoDB's apt repo may not offer arm64 packages for Debian bookworm (the `node_mongo` base). If so, fall back to MongoDB's per-arch `.deb` downloads or the Ubuntu repo for that image, so it stays multi-arch.
- Keep the existing CircleCI release jobs (`release-node_mongo`, `release-circleci_node_mongo`) and make sure they publish multi-arch.
- Update both READMEs and the root `README.md` references.
- Owning agent: `node`; root files (`version`, root `README.md`, CircleCI config if needed) by `architect`.

## Benefits
- Supported Node.js runtime and CircleCI base image.
- arm64 support.
- Modern, maintained MongoDB tooling (`mongosh` + database tools).
- Keeps the CircleCI and non-CircleCI `node_mongo` images consistent and versioned with their bases.
