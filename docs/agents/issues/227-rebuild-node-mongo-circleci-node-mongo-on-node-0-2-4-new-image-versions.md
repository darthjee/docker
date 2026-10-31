# Issue: Rebuild node_mongo / circleci_node_mongo on node 0.2.4 (new image versions)

## Description
`node_mongo` and `circleci_node_mongo` 0.2.2 are built on `darthjee/node:0.2.2` and `darthjee/circleci_node:0.2.2`. They have no `package.json` of their own and inherit their JS dependencies from the node images. The node images now ship the `express` 4.22.0 fix (CVE-2024-51999) in 0.2.4 (#226, merged), so these images must be rebuilt on the new base to pick it up.

## Problem
| Image | Latest version | Built on |
|---|---|---|
| `node_mongo` | 0.2.2 | `darthjee/node:0.2.2` (express 4.17.3) |
| `circleci_node_mongo` | 0.2.2 | `darthjee/circleci_node:0.2.2` (express 4.17.3) |

## Expected Behavior
- New version **0.2.3** for `node_mongo` and `circleci_node_mongo`, created with `bin/script.sh init`.
- `FROM` updated to `darthjee/node:0.2.4` / `darthjee/circleci_node:0.2.4`.
- `version` file updated: `node_mongo=0.2.3`, `circleci_node_mongo=0.2.3`.
- Each new version has a `README.md` (see `docs/agents/image-readme.md`), carried over from 0.2.2 with version/base references updated.
- Image tests pass, and CI releases these images after `node` / `circleci_node` (already wired in `.circleci/config.yml` via `requires`).

## Solution
- Copy `node_mongo/0.2.2` → `node_mongo/0.2.3` and `circleci_node_mongo/0.2.2` → `circleci_node_mongo/0.2.3` (via `bin/script.sh init`).
- Change only the `FROM` line in each Dockerfile; the 0.2.4 bases use the same OS bases as 0.2.2 (`node:22` / `cimg/node:22.14.0`), so the MongoDB install steps stay unchanged.
- Out of scope: bumping MongoDB series / tools versions or any other dependency.

## Dependencies
- Blocked by #226 (node / circleci_node 0.2.4) — **resolved**, merged in #233.
