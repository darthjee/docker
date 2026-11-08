# Plan: node 0.3.0: bump packages

Issue: [264-node-0-3-0-bump-packages.md](../../issues/264-node-0-3-0-bump-packages.md)

## Overview
Create `0.3.0` of `node` and `circleci_node` (part of epic #256). Keep Node 22, pin both base images to the same patch, move the `scripts` stage to `0.15.0`, and bump the npm packages without crossing a major version, pinning each one exactly.

## Context
- Both `0.2.4` images use `darthjee/scripts:0.11.0`. `node` is built on the floating `node:22` and `circleci_node` on `cimg/node:22.14.0`.
- `home/package.json` and `home/packages_sed.sed` are identical in both images. The package list mixes exact pins, `^`/`~` ranges and `latest`.
- `node_mongo` (#265) inherits from `node`, so these versions become its baseline (see #274: inherited images share their parent's versions).
- Only `circleci_node` has a `test/` folder (`yarn_cache.sh`, `user.sh`).
- Precedent: `rails_yarn` 2.0.0 (#261) bumped within major lines, pinned exact versions and used uppercase `AS`.

## Steps

- [01 — Create the 0.3.0 versions](node/01-init-versions.md)
- [02 — Update the Dockerfiles](node/02-dockerfiles.md)
- [03 — Pin and bump package.json](node/03-package-json.md)
- [04 — READMEs, build and test](node/04-readme-build-test.md)

## CI Checks
- `circleci_node`: `bin/script.sh test circleci_node` (the `test` job; there is no test folder for `node`).
- Release jobs `release-node` / `release-circleci_node` depend only on `release-scripts`, so nothing changes in `.circleci/config.yml`.

## Notes
- The target versions were looked up on 2026-11-08. Re-check them with `npm view <pkg>@<major> version` and the Docker Hub tag list before pinning. If a newer patch has come out on the same line, use it.
- No major bumps: eslint 9 needs flat config and `eslint-config-standard` 17 requires eslint 8, so the whole lint stack stays on its current majors.
- `node_mongo` / `circleci_node_mongo` are **not** touched here. They rebase onto 0.3.0 in #265.
