# Plan: Add README.md for darthjee/node

Main plan: [plan.md](plan.md)

## Overview
Write `node/0.2.2/README.md` in place (no `bin/script.sh init`, no new version, no rebuild), following the structure of `circleci_rails_gems/2.1.1/README.md`.

## Context
`bin/push_description.sh` reads `<image>/<version>/README.md`, with the version taken from the `version` file (`node=0.2.2`). That file is missing today. The image is built `FROM node:22`, runs as `node` with `/home/node/app` as working directory, and its builder stage runs `yarn_builder.sh` (from `darthjee/scripts:0.10.0`) over `home/package.json`. Only the new yarn cache entries are copied into `/usr/local/share/.cache/yarn/v6/` of the final image, so the packages are **pre-cached**, not installed.

## Implementation Steps

### Step 1 — Write `node/0.2.2/README.md`
Create the file with these sections:

1. Title `darthjee/node` underlined with `=` (same style as the template).
2. `## About the image`: built on top of the official `node:22` image; runs as the `node` user with `/home/node/app` as working directory; intended as a base for Node.js projects; ships a warm yarn cache so common packages resolve from cache on `yarn install` instead of being downloaded.
3. `## Pre-cached packages`: explain they live in the global yarn cache (`/usr/local/share/.cache/yarn/v6/`) and are used when a project's `package.json` asks for them. List names only (no version ranges), grouped:
   - `### Dependencies`: `express`, `underscore`
   - `### Development`: `express-generator`, `sass`
   - `### Linting`: `eslint`, `eslint-config-standard`, `eslint-plugin-complexity`, `eslint-plugin-import`, `eslint-plugin-jasmine`, `eslint-plugin-n`, `eslint-plugin-promise`, `eslint-plugin-react`, `eslint-plugin-react-hooks`
   - `### Test and quality`: `jasmine`, `nyc`, `plato`
4. `## How to use`: a `dockerfile` example with `FROM darthjee/node:<version>` (no hardcoded tag; point to https://hub.docker.com/r/darthjee/node/tags), copying `package.json` and running `yarn install`.
5. `## License`: "See the LICENSE file for more information." (same as the template).

Write in English. Do not touch the Dockerfile, `home/`, `node/0.2.1/`, `circleci_node`, or any child image.

## Files to Change
- `node/0.2.2/README.md` — new file, Docker Hub description of `darthjee/node`.

## Notes
- No CI job validates README content; verify manually that every listed package matches `node/0.2.2/home/package.json`.
- `bin/script.sh push_description node` will still exit 1 until `circleci_node/<version>/README.md` exists (separate sub-issue of #153).
- The `COPY --chown=app:app` line in the Dockerfile is out of scope.
