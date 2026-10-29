# Plan: Add README.md for darthjee/circleci_node

Main plan: [plan.md](plan.md)

## Overview
Write `circleci_node/0.2.2/README.md` in place (no `bin/script.sh init`, no new version, no rebuild), following the structure of `circleci_rails_gems/2.1.1/README.md` and reusing the wording of `node/0.2.2/README.md` (#156) so both Docker Hub pages read as one family.

## Context
`bin/push_description.sh node` pushes `node/0.2.2/README.md` and then requires `circleci_node/<version>/README.md` (version from the `version` file: `circleci_node=0.2.2`), which is missing today. The image is built `FROM cimg/node:22.14.0` with `/home/circleci/project` as working directory. Its builder stage runs `yarn_builder.sh` over `home/package.json` (identical to `node/0.2.2/home/package.json`) and only the new yarn cache entries are copied into `/usr/local/share/.cache/yarn/v6/`, so packages are **pre-cached**, not installed. The final image currently runs as `root` (tracked in #178) — the README must not name a runtime user.

## Implementation Steps

### Step 1 — Write `circleci_node/0.2.2/README.md`
Create the file beside `home/` (never under `home/`, which `ADD home/*` copies into the image) with these sections:

1. Title `darthjee/circleci_node` underlined with `=`.
2. `## About the image`:
   - CircleCI-optimized image with Node.js 22, based on `cimg/node` (no patch version).
   - The CircleCI counterpart of [`darthjee/node`](https://hub.docker.com/r/darthjee/node); both pre-cache the same packages.
   - Working directory `/home/circleci/project`. Do not mention which user the image runs as.
   - One line: `cimg/node` already provides yarn, npm, git and the usual CircleCI tooling.
   - Warm yarn cache: common packages resolve from the cache on `yarn install` instead of being downloaded.
3. `## Pre-cached packages`: copy the intro paragraph and the groups from `node/0.2.2/README.md` verbatim (names only, no versions):
   - `### Dependencies`: `express`, `underscore`
   - `### Development`: `express-generator`, `sass`
   - `### Linting`: `eslint`, `eslint-config-standard`, `eslint-plugin-complexity`, `eslint-plugin-import`, `eslint-plugin-jasmine`, `eslint-plugin-n`, `eslint-plugin-promise`, `eslint-plugin-react`, `eslint-plugin-react-hooks`
   - `### Test and quality`: `jasmine`, `nyc`, `plato`
4. `## How to use` (link https://hub.docker.com/r/darthjee/circleci_node/tags for available tags; never hardcode a tag):
   1. As the CircleCI job executor image:

      ```yaml
      jobs:
        test:
          docker:
            - image: darthjee/circleci_node:<version>
          steps:
            - checkout
            - run: yarn install
            - run: yarn test
      ```

   2. A short `dockerfile` example `FROM darthjee/circleci_node:<version>` for projects building their own CI image on top of it.

   Close with one sentence that `yarn install` resolves the pre-cached packages from the warm cache.
5. `## License`: "See the LICENSE file for more information."

Write in English. Make no claim about supported architectures, do not list child images, and do not touch the Dockerfile, `home/`, `circleci_node/0.2.1/`, or any other image.

## Files to Change
- `circleci_node/0.2.2/README.md` — new file, Docker Hub description of `darthjee/circleci_node`.
