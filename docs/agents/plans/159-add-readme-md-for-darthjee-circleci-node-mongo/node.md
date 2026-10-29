# Plan: Add README.md for darthjee/circleci_node_mongo

Issue: [159-add-readme-md-for-darthjee-circleci-node-mongo.md](../../issues/159-add-readme-md-for-darthjee-circleci-node-mongo.md)

## Overview
Write `circleci_node_mongo/0.0.6/README.md` so `bin/push_description.sh` can push it as the Docker Hub description of `darthjee/circleci_node_mongo`. Documentation only: no Dockerfile change, no new version, no rebuild.

## Context
- `circleci_node_mongo/0.0.6/Dockerfile` is `FROM darthjee/circleci_node:0.0.7`, switches to `USER root`, runs `apt-get install -y mongodb-clients`, then `USER circleci`. The folder has no `home/`.
- `darthjee/circleci_node:0.0.7` (removed from the repo; see `git show 7fec070^:circleci_node/0.0.7/Dockerfile`) is `FROM circleci/node:10.7`, uses workdir `/home/circleci/project`, and runs `npm -g install` of: `express`, `underscore`, `express-generator`, `jasmine`, `jasmine-core`, `eslint`, `eslint-plugin-jasmine`, `nock`, `jsdoc`.
- That base is legacy: Node.js 10 (EOL) on the deprecated `circleci/node` image. The rebuild is tracked in #182 and is out of scope.
- Reference READMEs: `node_mongo/0.0.6/README.md` (non-CircleCI counterpart, merged in #158 — mirror its wording and flat package list), `circleci_node/0.2.2/README.md` (CircleCI "How to use" shape), `circleci_rails_gems/2.1.1/README.md` (overall structure).

## Implementation Steps

### Step 1 — Write `circleci_node_mongo/0.0.6/README.md`
Create the file beside the `Dockerfile` with, in order:

1. Title `darthjee/circleci_node_mongo` underlined with `=`.
2. `## About the image`: a CircleCI image with Node.js 10 and the MongoDB command-line clients (`mongodb-clients`, installed from apt), built on top of [`darthjee/circleci_node`](https://hub.docker.com/r/darthjee/circleci_node) `0.0.7`, itself built on `circleci/node:10.7`. It is the CircleCI counterpart of [`darthjee/node_mongo`](https://hub.docker.com/r/darthjee/node_mongo), designed to run tests for Node.js + MongoDB projects on circleci.com. Then exactly:
   `> **Note:** This is a legacy image built on an old, end-of-life Node.js base (the deprecated `circleci/node` image).`
   (no issue link). Then: working directory `/home/circleci/project`, runs as the `circleci` user.
3. `## Pre-installed packages`:
   - `### Globally installed npm packages` — "installed globally (`npm -g install`) by the base image", flat list without versions: `express`, `underscore`, `express-generator`, `jasmine`, `jasmine-core`, `eslint`, `eslint-plugin-jasmine`, `nock`, `jsdoc`.
   - `### Tools` — `mongodb-clients` (MongoDB command-line clients, e.g. the `mongo` shell), useful for seeding or inspecting a MongoDB service container in the job.
4. `## How to use`: intended for CircleCI pipelines of Node.js projects using MongoDB (see the available tags at https://hub.docker.com/r/darthjee/circleci_node_mongo/tags). Two numbered options:
   1. As the job executor in `.circleci/config.yml`:
      ```yaml
      jobs:
        test:
          docker:
            - image: darthjee/circleci_node_mongo:<version>
            - image: mongo:<version>
          steps:
            - checkout
            - run: npm install
            - run: npm test
      ```
   2. As a base image in a `Dockerfile`:
      ```dockerfile
      FROM darthjee/circleci_node_mongo:<version>

      COPY package.json /home/circleci/project/
      RUN npm install
      ```
5. `## License`: "See the LICENSE file for more information."

Do not hardcode a version tag, do not make architecture claims, and do not mention yarn caches.

## Files to Change
- `circleci_node_mongo/0.0.6/README.md` — new file, the image's Docker Hub description.

## Notes
- No Dockerfile, `version` file, or other README changes (no back-link from `node_mongo`).
- No automated tests; verified manually on Docker Hub after the next release.
