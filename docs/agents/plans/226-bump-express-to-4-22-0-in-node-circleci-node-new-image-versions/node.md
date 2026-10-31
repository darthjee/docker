# Plan: Bump express to 4.22.0 in node / circleci_node (new image versions)

Issue: [226-bump-express-to-4-22-0-in-node-circleci-node-new-image-versions.md](../../issues/226-bump-express-to-4-22-0-in-node-circleci-node-new-image-versions.md)

## Overview
Release `node` 0.2.4 (from 0.2.2) and `circleci_node` 0.2.4 (from 0.2.3), both pinning `express` to `4.22.0`. This supersedes Dependabot PRs #150 and #151 and unblocks #227 (`node_mongo` rebase).

## Context
- `node/0.2.2` and `circleci_node/0.2.3` both pin `"express": "4.17.3"` in `home/package.json`, which is vulnerable to CVE-2024-51999 (GHSA-pj86-cfqh-vqx6).
- `version` currently has `node=0.2.2`, `circleci_node=0.2.3` and `scripts=0.11.0`.
- `node/0.2.2/Dockerfile` builds FROM `darthjee/scripts:0.10.0`. `circleci_node/0.2.3` already uses `0.11.0`. Between scripts 0.10.0 and 0.11.0 only `deploy_frontend.sh` changed, so `yarn_builder.sh`, which node uses, is unaffected.
- How `bin/script.sh init <image> [version]` (`bin/init.sh`) works:
  - For each of `<image>`, `circleci_<image>` and `production_<image>`, it copies `<prefix><image>/<current version of <image>>` to the new version, using the **base image's** current version.
  - It sets every prefix's entry in `version` to the new version.
  - It rewrites each `FROM darthjee/<x>:<v>` line to the version listed in `version`.
  - So `init node 0.2.4` copies `circleci_node/0.2.2`, **not 0.2.3**, and also bumps node's scripts stage to `0.11.0` on its own.
- The READMEs list package names only, without express versions or scripts tags, so their content needs no change.

## Implementation Steps

### Step 1 — Create the 0.2.4 versions
1. Run `bin/script.sh init node 0.2.4`. This creates `node/0.2.4` (from 0.2.2, FROM `darthjee/scripts:0.11.0`) and `circleci_node/0.2.4`, which is wrongly copied from 0.2.2. It also sets `node=0.2.4` and `circleci_node=0.2.4` in `version`.
2. Replace the wrong copy: `rm -rf circleci_node/0.2.4 && cp -R circleci_node/0.2.3 circleci_node/0.2.4`. This keeps 0.2.3's `circleci` user changes, the yarn cache path, and the `test/` folder.
3. Confirm `node/0.2.4/Dockerfile` starts with `FROM darthjee/scripts:0.11.0 as scripts`, and `circleci_node/0.2.4/Dockerfile` too. Confirm `version` reads `node=0.2.4` and `circleci_node=0.2.4`, and that no other line changed.
4. Each of `node/0.2.4` and `circleci_node/0.2.4` must end up with a `README.md`. Both come from the copies.

### Step 2 — Pin express and verify
1. In `node/0.2.4/home/package.json` and `circleci_node/0.2.4/home/package.json`, change `"express": "4.17.3"` to `"express": "4.22.0"`.
2. Run `bin/script.sh build node`, which also builds `circleci_node`. `node` 0.2.4 only needs to build: it has no `test/` folder, and adding one is out of scope.
3. Run `bin/script.sh test circleci_node`. The 0.2.4 suite copied from 0.2.3 (`user.sh`, `yarn_cache.sh`) must pass.

## Files to Change
- `node/0.2.4/` (new, copied from 0.2.2) — `Dockerfile` (scripts `0.11.0`, set by init), `home/package.json` (express `4.22.0`), `home/packages_sed.sed`, `README.md`
- `circleci_node/0.2.4/` (new, copied from **0.2.3**) — `home/package.json` (express `4.22.0`), plus unchanged `Dockerfile`, `README.md`, `home/packages_sed.sed`, `test/`
- `version` — `node=0.2.4`, `circleci_node=0.2.4`

## CI Checks
- `node`, `circleci_node`: `bin/script.sh build node` and `bin/script.sh test circleci_node`. The release jobs are `release-node` and `release-circleci_node`, both driven by `version`.

## Notes
- Do not edit the released folders `node/0.2.2` or `circleci_node/0.2.2` / `0.2.3`.
- `node_mongo` / `circleci_node_mongo` are not touched here. Rebasing them onto 0.2.4 is #227.
- After merge, close Dependabot PRs #150 and #151 as superseded. This is a manual/GitHub step, not a code change.
