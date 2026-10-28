# Issue: Add README.md for darthjee/node

## Description

Add `node/0.2.2/README.md` describing the `darthjee/node` image, so it can be pushed as the Docker Hub description of `darthjee/node` (see `bin/push_description.sh`).

The image is built from `node:22` (see `node/0.2.2/Dockerfile`). It runs as the `node` user with `/home/node/app` as working directory. A builder stage runs `yarn_builder.sh` (from `darthjee/scripts:0.10.0`) against `home/package.json`, and only the resulting yarn cache entries are copied into the final image at `/usr/local/share/.cache/yarn/v6/`. The packages are therefore **pre-cached** (a project's `yarn install` resolves them from the warm cache), not installed into a `node_modules`.

Parent epic: #153

## Problem

`darthjee/node` has no README, so its Docker Hub page has no description, and `bin/script.sh push_description node` exits with `Error: README not found at node/0.2.2/README.md`.

## Expected Behavior

`node/0.2.2/README.md` exists, accurately describes the image, and `bin/push_description.sh` finds it for `darthjee/node`.

## Solution

### Conventions

- Follow the structure of `circleci_rails_gems/2.1.1/README.md`: `darthjee/node` title, *About the image*, pre-cached packages, *How to use*, *License*.
- Add the file **in place** in the current version folder (`node/0.2.2/`): no `bin/script.sh init`, no new version, no rebuild. `README.md` sits beside `home/` and is never copied into the image (no layer impact).
- Do **not** hardcode a version tag in usage examples (use e.g. `FROM darthjee/node:<version>` and point to the Docker Hub tags list), so the README does not go stale on future `init`s.
- Use "pre-cached" wording for the packages, not "pre-installed", and explain that they are served from the yarn cache on `yarn install`.
- Write in English.

### Content

- *About the image*: built on `node:22`; `node` user; `/home/node/app` working directory; purpose as a base for Node.js projects with a warm yarn cache.
- *Pre-cached packages*, listed from `home/package.json` (names only, no version ranges, so the README doesn't drift with minor bumps):
  - Dependencies: `express`, `underscore`.
  - Development: `express-generator`, `sass`.
  - Linting: `eslint`, `eslint-config-standard`, `eslint-plugin-complexity`, `eslint-plugin-import`, `eslint-plugin-jasmine`, `eslint-plugin-n`, `eslint-plugin-promise`, `eslint-plugin-react`, `eslint-plugin-react-hooks`.
  - Test and quality: `jasmine`, `nyc`, `plato`.
- *How to use*: `FROM darthjee/node:<version>`, copy `package.json`, run `yarn install`.
- *License*: same as the template.

### Scope

In scope:

- `node/0.2.2/README.md` only (the current version per `version`, the only path `bin/push_description.sh` reads).

Out of scope:

- Backfilling `node/0.2.1/` (past version; differs from 0.2.2 only in the `darthjee/scripts` stage tag, and no README is ever read from it).
- `circleci_node` and child images (`node_mongo`, `ruby_node`, ...) — each has its own sub-issue under #153.
- Any Dockerfile change (including the `COPY --chown=app:app` line).
- Pushing the description to Docker Hub (CI sub-issue).

### Dependencies

- None. Counterpart images depend on this one and will reuse its structure.
- Pushing to Docker Hub is handled by the CI sub-issue; this issue only adds the file.
- `bin/script.sh push_description node` also pushes `circleci_node` and exits 1 while `circleci_node/<version>/README.md` is missing, so pushing the `node` family keeps failing until the `circleci_node` sub-issue lands too.

### Responsible agent

`node`

### Testing

No automated tests. Verify that every listed package matches `node/0.2.2/home/package.json`, and after the next release tag that the `darthjee/node` Docker Hub page shows this README.

## Benefits

- `darthjee/node` gets a meaningful Docker Hub page explaining what it provides and how to build on it.
- Establishes the README shape for the Node family counterparts.
