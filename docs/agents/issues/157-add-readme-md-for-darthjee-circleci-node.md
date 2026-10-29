# Issue: Add README.md for darthjee/circleci_node

## Description

Add `circleci_node/0.2.2/README.md` describing the `darthjee/circleci_node` image, so it can be pushed as the Docker Hub description of `darthjee/circleci_node` by `bin/push_description.sh`.

The image is built from `cimg/node:22.14.0` (see `circleci_node/0.2.2/Dockerfile`) and is the CircleCI counterpart of `darthjee/node`. Its `home/package.json` is identical to `node/0.2.2/home/package.json`, so both images pre-cache the same packages.

Parent epic: #153

## Problem

`darthjee/circleci_node` has no README, so its Docker Hub page has no description. Since `bin/push_description.sh` fails when a `circleci_`/`production_` variant folder exists without a README, `bin/script.sh push_description node` keeps failing for the whole node family even though the `darthjee/node` README (#156) has landed.

## Expected Behavior

- `circleci_node/0.2.2/README.md` exists, following the structure of `circleci_rails_gems/2.1.1/README.md` and the wording of `node/0.2.2/README.md` (#156), so the two Docker Hub pages read as one family.
- `bin/script.sh push_description node` succeeds for both `darthjee/node` and `darthjee/circleci_node` (there is no `production_node`).

## Solution

### Conventions

- Add the file **in place** in the current version folder (`circleci_node/0.2.2/`), beside `home/` — never under `home/` (`ADD home/*` would copy it into the builder stage). No `bin/script.sh init`, no new version, no rebuild; no layer or digest changes.
- Do **not** hardcode a version tag in usage examples; use `<version>` and link to the Docker Hub tags list.
- Write in English.

### Content

1. **Title:** `darthjee/circleci_node`, underlined with `=`.
2. **About the image:**
   - CircleCI-optimized image with Node.js 22, based on `cimg/node` (no patch version).
   - The CircleCI counterpart of [`darthjee/node`](https://hub.docker.com/r/darthjee/node); both pre-cache the same `package.json` packages.
   - Working directory `/home/circleci/project`. Do **not** state a runtime user: the final image currently runs as `root` (the base stage's `USER root` is never reverted), tracked separately in #178.
   - One line noting `cimg/node` already provides yarn, npm, git and the usual CircleCI tooling, rather than listing them.
   - Warm yarn cache explanation.
3. **Pre-cached packages** (not "pre-installed": `yarn_builder.sh` only warms `/usr/local/share/.cache/yarn/v6/`; there is no `node_modules`). Names only, no versions, same groups and wording as `node/0.2.2/README.md`:
   - Dependencies: `express`, `underscore`
   - Development: `express-generator`, `sass`
   - Linting: `eslint`, `eslint-config-standard`, `eslint-plugin-complexity`, `eslint-plugin-import`, `eslint-plugin-jasmine`, `eslint-plugin-n`, `eslint-plugin-promise`, `eslint-plugin-react`, `eslint-plugin-react-hooks`
   - Test and quality: `jasmine`, `nyc`, `plato`
4. **How to use** — both usages, executor first, linking to https://hub.docker.com/r/darthjee/circleci_node/tags:
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

   2. A short `FROM darthjee/circleci_node:<version>` example for projects building their own CI image on top of it.

   Close with a sentence that `yarn install` resolves the pre-cached packages from the warm cache.
5. **License:** same line as the template (`See the LICENSE file for more information.`).

### Out of scope

- Backfilling `circleci_node/0.2.1/` (`bin/push_description.sh` only reads the current version).
- `circleci_node_mongo` and other child images (own sub-issues under #153); the README does not list child images.
- Any Dockerfile change (runtime user / builder `--chown=node:node` — see #178).
- Any claim about supported architectures (Docker Hub's tags page shows per-tag platforms; multi-arch for the node family is tracked in #148).
- Pushing the description to Docker Hub (handled by the CI sub-issue).

### Responsible agent

`node`

### Testing

No automated tests. Verify manually that `bin/script.sh push_description node` no longer fails on the missing `circleci_node` README, and after the next release the `darthjee/circleci_node` Docker Hub page shows it.

## Benefits

- `darthjee/circleci_node` gets a useful Docker Hub page, consistent with `darthjee/node`.
- Unblocks `push_description` for the node family, moving epic #153 forward.
