# Node Plan: Rebuild node_mongo / circleci_node_mongo on node 0.2.4 (new image versions)

Main plan: [plan.md](plan.md)

## Overview
Bump `node_mongo` and `circleci_node_mongo` from 0.2.2 to 0.2.3, with the only Dockerfile change being the `FROM` line pointing at the 0.2.4 node bases (already on main, `version` has `node=0.2.4` / `circleci_node=0.2.4`).

## Context
- `node_mongo/0.2.2` is `FROM darthjee/node:0.2.2`; `circleci_node_mongo/0.2.2` is `FROM darthjee/circleci_node:0.2.2`. Neither has its own `package.json`; JS deps (incl. express) come from the base.
- The 0.2.4 bases keep the same upstream images as 0.2.2 (`node:22` / `cimg/node:22.14.0`), so the MongoDB install steps (Debian apt repo + per-arch tools `.deb` for `node_mongo`; Ubuntu apt repo for `circleci_node_mongo`) stay valid unchanged.
- `bin/script.sh init node_mongo` (see `bin/init.sh`) iterates over `""`, `circleci_`, `production_` prefixes: it copies `<image>/0.2.2` → `<image>/0.2.3` for both `node_mongo` and `circleci_node_mongo` (no `production_node_mongo` exists, so it is skipped), bumps both entries in `version`, and rewrites every `FROM darthjee/<img>:<old>` line to the version listed in `version` — i.e. `node:0.2.4` / `circleci_node:0.2.4`.
- CI release ordering is already wired in `.circleci/config.yml` (`release-node_mongo` requires `release-node`, `release-circleci_node_mongo` requires `release-circleci_node`); no CI change needed.

## Implementation Steps

### Step 1 — Init the new versions
From the repo root, run `bin/script.sh init node_mongo` (it auto-increments 0.2.2 → 0.2.3). Then verify:
- `node_mongo/0.2.3/Dockerfile` starts with `FROM darthjee/node:0.2.4`, and `circleci_node_mongo/0.2.3/Dockerfile` with `FROM darthjee/circleci_node:0.2.4`; the rest of each Dockerfile is identical to 0.2.2.
- `version` now has `node_mongo=0.2.3` and `circleci_node_mongo=0.2.3`, and nothing else in `version` changed (no stray `aux` file left behind).
- Each 0.2.3 folder has a `README.md` copied from 0.2.2. The READMEs use `<version>` placeholders and describe the base generically, so no edits are needed; double-check against `docs/agents/image-readme.md` and only adjust if something is version-specific.

The `version` file is at the repo root, outside the node agent's image directories, but this edit is produced by the project's own `init` script as part of the standard versioning flow and is in scope for this issue.

### Step 2 — Build and test both images
Build both images locally (needs the 0.2.4 bases available — they are published, or build them first with `bin/script.sh build node` / `circleci_node`) and run the (no-op) tests:

```bash
bin/script.sh pre_build node_mongo && bin/script.sh build node_mongo && bin/script.sh test node_mongo
bin/script.sh pre_build circleci_node_mongo && bin/script.sh build circleci_node_mongo && bin/script.sh test circleci_node_mongo
```

Optionally sanity-check inside each built image that `mongosh --version` and `mongodump --version` work, and that the yarn cache holds `express` 4.22.0.

## Files to Change
- `node_mongo/0.2.3/Dockerfile` — new, copy of 0.2.2 with `FROM darthjee/node:0.2.4`.
- `node_mongo/0.2.3/README.md` — new, copy of 0.2.2.
- `circleci_node_mongo/0.2.3/Dockerfile` — new, copy of 0.2.2 with `FROM darthjee/circleci_node:0.2.4`.
- `circleci_node_mongo/0.2.3/README.md` — new, copy of 0.2.2.
- `version` — `node_mongo=0.2.3`, `circleci_node_mongo=0.2.3`.

## CI Checks
- `node_mongo`, `circleci_node_mongo`: `bin/script.sh test <image>` — no `test/` folder, prints `no tests for <image>` and returns 0. Release happens on tag via `release-node_mongo` / `release-circleci_node_mongo`.

## Notes
- Do not modify the 0.2.2 folders.
- Out of scope: bumping `MONGODB_SERIES`, `MONGODB_TOOLS_VERSION`, or any other dependency.
- If `init` ever picked a different target version (e.g. because `version` was edited concurrently), pass it explicitly: `bin/script.sh init node_mongo 0.2.3`.
