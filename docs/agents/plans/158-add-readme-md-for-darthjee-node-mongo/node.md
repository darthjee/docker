# Plan: Add README.md for darthjee/node_mongo

Issue: [158-add-readme-md-for-darthjee-node-mongo.md](../../issues/158-add-readme-md-for-darthjee-node-mongo.md)

## Overview
Write `node_mongo/0.0.6/README.md` in place (no `bin/script.sh init`, no new version, no Dockerfile change), documenting what `darthjee/node_mongo:0.0.6` really contains. It is **not** a copy of the `darthjee/node:0.2.2` README.

## Context
- `node_mongo/0.0.6/Dockerfile` is `FROM darthjee/node:0.0.7`, switches to `root`, runs `apt-get install -y mongodb-clients`, then switches back to `USER node`. There is no `home/` folder.
- `darthjee/node:0.0.7` (removed from the repo; see `git show 5345eba:node/0.0.7/Dockerfile` and `git show 5345eba:node/0.0.7/home/package.json`) is `FROM node:10.7`, workdir `/home/node/app`, and installs, **globally** with `npm -g install`, the `dependencies` and `devDependencies` of its `package.json`:
  - dependencies: `express`, `underscore`
  - devDependencies: `express-generator`, `jasmine`, `jasmine-core`, `eslint`, `eslint-plugin-jasmine`, `nock`, `jsdoc`
- Node.js 10 is end of life. Rebuilding on `darthjee/node:0.2.2` is out of scope (#180).
- Wording/structure references: `circleci_rails_gems/2.1.1/README.md`, `node/0.2.2/README.md`, `circleci_node/0.2.2/README.md`.

## Implementation Steps

### Step 1 — Write `node_mongo/0.0.6/README.md`
Create the file beside the `Dockerfile` with:

1. Title `darthjee/node_mongo` underlined with `=`.
2. `## About the image`:
   - A Node.js 10 image with the MongoDB command-line clients (`mongodb-clients`, from apt), built on top of [`darthjee/node`](https://hub.docker.com/r/darthjee/node) `0.0.7`, itself built on the official `node:10.7` image.
   - A short note (e.g. a `> **Note:**` blockquote) that this is a legacy image on an old, end-of-life Node.js base.
   - Working directory `/home/node/app`; runs as the `node` user.
3. `## Pre-installed packages`:
   - `### Globally installed npm packages` — state that they are installed globally (`npm -g install`) by the base image, then list: `express`, `underscore`, `express-generator`, `jasmine`, `jasmine-core`, `eslint`, `eslint-plugin-jasmine`, `nock`, `jsdoc`.
   - `### Tools` — `mongodb-clients` (MongoDB command-line clients, e.g. the `mongo` shell).
   - Do **not** state package versions, and do **not** mention a yarn cache.
4. `## How to use` — link to https://hub.docker.com/r/darthjee/node_mongo/tags, then a `Dockerfile` example with no hardcoded tag:

   ```dockerfile
   FROM darthjee/node_mongo:<version>

   COPY package.json /home/node/app/
   RUN npm install
   ```

5. `## License` — `See the LICENSE file for more information.`

No architecture claims, no list of child/counterpart images beyond the `darthjee/node` link.

## Files to Change
- `node_mongo/0.0.6/README.md` — new file (Docker Hub description of `darthjee/node_mongo`).

## Notes
- Do not touch `node_mongo/0.0.6/Dockerfile`, `version`, or any other image.
- `circleci_node_mongo` has its own sub-issue; keep the wording reusable for it.
