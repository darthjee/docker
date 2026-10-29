# Issue: Add README.md for darthjee/circleci_node_mongo

## Description

Add `circleci_node_mongo/0.0.6/README.md` describing the `darthjee/circleci_node_mongo` image, so it can be pushed as its Docker Hub description (see `bin/push_description.sh`). Part of epic #153.

The image is built `FROM darthjee/circleci_node:0.0.7` (itself on `circleci/node:10.7`) and only adds `mongodb-clients` (installed as `root`, then back to `USER circleci`). It is the CircleCI counterpart of `darthjee/node_mongo`, whose README was added in #158 (PR #181).

## Problem

The image has no README, so its Docker Hub page has no description and `bin/script.sh push_description` fails for its family. Its base is also stale: Node.js 10 (end of life since 2021) on CircleCI's deprecated legacy `circleci/node:10.7` image; the only published tags (`0.0.6`, `latest`) date from 2018 and are amd64-only.

## Expected Behavior

`circleci_node_mongo/0.0.6/README.md` exists, accurately describes the `0.0.6` image as it really is (including that its base is legacy/end-of-life), links to its `darthjee/node_mongo` counterpart, and becomes the Docker Hub description of `darthjee/circleci_node_mongo` on the next release.

## Solution

### Conventions

- Follow the structure of `circleci_rails_gems/2.1.1/README.md`, with wording aligned to the merged `node_mongo/0.0.6/README.md`.
- Add the file **in place** in `circleci_node_mongo/0.0.6/`: no `bin/script.sh init`, no new version, no rebuild, no Dockerfile changes. `README.md` sits beside the `Dockerfile` (this version has no `home/` folder) and is never copied into the image.
- Do **not** hardcode a version tag in examples (use `<version>` and point to the Docker Hub tags list).
- Write in English.

### Content

- **Title**: `darthjee/circleci_node_mongo`, underlined with `=`.
- **About the image**: CircleCI image with Node.js 10 and the MongoDB command-line clients, built on [`darthjee/circleci_node`](https://hub.docker.com/r/darthjee/circleci_node) 0.0.7, which is built on `circleci/node:10.7`. It is the CircleCI counterpart of [`darthjee/node_mongo`](https://hub.docker.com/r/darthjee/node_mongo), designed to run tests for Node.js + MongoDB projects on circleci.com. Followed by the note `> **Note:** This is a legacy image built on an old, end-of-life Node.js base (the deprecated `circleci/node` image).` — no issue link (a bare `#182` would not resolve on Docker Hub). Working directory `/home/circleci/project`, user `circleci`.
- **Pre-installed packages** — a single flat *Globally installed npm packages* list (installed globally with `npm -g install` by the base image, no versions): `express`, `underscore`, `express-generator`, `jasmine`, `jasmine-core`, `eslint`, `eslint-plugin-jasmine`, `nock`, `jsdoc`.
- **Tools**: `mongodb-clients` (the `mongo` shell and related client tools), e.g. for seeding or inspecting a MongoDB service container in the job.
- **How to use**: link to https://hub.docker.com/r/darthjee/circleci_node_mongo/tags, then
  1. as the CircleCI job executor in `.circleci/config.yml`, alongside a `mongo:<version>` service container, with `checkout`, `npm install`, `npm test` steps;
  2. as a base image: `FROM darthjee/circleci_node_mongo:<version>`, `COPY package.json /home/circleci/project/`, `RUN npm install`.
- **License**: "See the LICENSE file for more information."

### Counterparts, layers and architectures

- No back-link is added to the `node_mongo` README (out of scope; the node family has no back-links today).
- No image is built `FROM darthjee/circleci_node_mongo`; no child images are affected.
- No layer impact (the Dockerfile has no `COPY`/`ADD`).
- The README makes **no architecture claims**.

### Out of scope

- Rebuilding on `darthjee/circleci_node:0.2.2` (including multi-arch `linux/amd64` + `linux/arm64` publishing): #182, counterpart of #180.
- Pushing descriptions to Docker Hub from CI: handled by the epic's CI sub-issue.

### Responsible agent

`node`

### Testing

No automated tests. Verified manually after the next release tag: the `darthjee/circleci_node_mongo` Docker Hub page shows this README.
