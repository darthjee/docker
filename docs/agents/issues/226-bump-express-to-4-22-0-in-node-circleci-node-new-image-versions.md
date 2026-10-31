# Issue: Bump express to 4.22.0 in node / circleci_node (new image versions)

## Description

Dependabot opened #150 and #151 to bump `express` from 4.17.3 to 4.22.0. That release fixes CVE-2024-51999 (GHSA-pj86-cfqh-vqx6). Both PRs edit `home/package.json` in an already-released version folder (`node/0.2.2`, `circleci_node/0.2.2`) and don't create a new image version, so they can't be merged as they are.

## Problem

The latest versions on `main` still pin the vulnerable version:

| Image | Latest version | `express` | `scripts` base |
|---|---|---|---|
| `node` | 0.2.2 | 4.17.3 | 0.10.0 |
| `circleci_node` | 0.2.3 | 4.17.3 | 0.11.0 |

## Expected Behavior

- New version **0.2.4** for `node` (from 0.2.2) and `circleci_node` (from 0.2.3), created with `bin/script.sh init`. Both images use the same version again.
- `home/package.json` pins `express` to `4.22.0` in both new versions.
- `node/0.2.4/Dockerfile` also moves its scripts stage from `darthjee/scripts:0.10.0` to `darthjee/scripts:0.11.0`, matching `circleci_node`.
- `version` file updated: `node=0.2.4`, `circleci_node=0.2.4`.
- Each new version has a `README.md` (see `docs/agents/image-readme.md`).
- Verification:
  - `node` 0.2.4 builds. It has no `test/` folder, and adding one is out of scope.
  - `circleci_node` 0.2.4 carries its `test/` folder over from 0.2.3, and the tests pass (`bin/script.sh test circleci_node`).
- After merge, close #150 and #151 as superseded.

## Dependencies

- Blocks #227 (`node_mongo` rebase), which must be built on the new versions to pick up the fix.
