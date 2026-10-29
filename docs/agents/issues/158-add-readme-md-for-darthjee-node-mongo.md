# Issue: Add README.md for darthjee/node_mongo

## Description

Add `node_mongo/0.0.6/README.md` describing the `darthjee/node_mongo` image, so it can be pushed as the Docker Hub description of `darthjee/node_mongo` (see `bin/push_description.sh`).

The image is built `FROM darthjee/node:0.0.7` (see `node_mongo/0.0.6/Dockerfile`) — an old base on Node.js 10.7, not the current `darthjee/node:0.2.2`.

Parent epic: #153

## Problem

The image has no README, so its Docker Hub page has no description and `bin/script.sh push_description` fails for the node family. Copying the `darthjee/node:0.2.2` README wording would misdescribe this image, whose base and package set are entirely different.

## Expected Behavior

`node_mongo/0.0.6/README.md` exists and accurately describes what `darthjee/node_mongo:0.0.6` actually contains, and `push_description` can push it to Docker Hub.

## Solution

### Conventions

- Follow the structure of `circleci_rails_gems/2.1.1/README.md`: `darthjee/node_mongo` title, *About the image*, pre-installed packages/tools, *How to use*, *License*.
- Add the file **in place** in `node_mongo/0.0.6/`: no `bin/script.sh init`, no new version, no rebuild, no Dockerfile change. There is no `home/` folder; `README.md` sits beside the `Dockerfile`.
- Do **not** hardcode a version tag in usage examples (use `FROM darthjee/node_mongo:<version>` and link to https://hub.docker.com/r/darthjee/node_mongo/tags).
- Write in English.

### Content

Document `0.0.6` **as it actually is**:

- Node.js 10.7 (via `darthjee/node:0.0.7`, built on `node:10.7`), with a short note that this is an old, end-of-life Node.js base.
- Packages installed **globally** (`npm -g install`) by the base image: express, underscore, express-generator, jasmine, jasmine-core, eslint, eslint-plugin-jasmine, nock, jsdoc. Do **not** copy the `darthjee/node:0.2.2` pre-cached package list.
- `mongodb-clients` installed via apt on top of the base (MongoDB command-line clients, e.g. the `mongo` shell).
- Workdir `/home/node/app`; runs as the `node` user.
- No architecture claims.

### Out of scope

- Rebuilding the image on `darthjee/node:0.2.2` — tracked in #180 (a new version, whose README will reuse the `darthjee/node` package list).
- The `circleci_node_mongo` README (its own sub-issue).

### Responsible agent

`node`

### Testing

No automated tests. Verified manually after the next release tag: the `darthjee/node_mongo` Docker Hub page shows this README.
