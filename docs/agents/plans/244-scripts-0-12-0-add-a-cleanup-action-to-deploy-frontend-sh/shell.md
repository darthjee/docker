# Shell Plan: scripts 0.12.0: add a cleanup action to deploy_frontend.sh

Main plan: [plan.md](plan.md)

## Overview
Add a `cleanup` action to `deploy_frontend.sh` in a new `scripts/0.12.0` image version. Over SSH, it removes the `${SSH_REMOTE_TEMP_DIR}-*` staging folders older than `CLEANUP_MAX_AGE_MINUTES` (default `1440`), never touching the live folder, the plain `SSH_REMOTE_TEMP_DIR`, or the current workflow's staging folder.

## Context
Since `0.11.0`, each workflow stages into `${SSH_REMOTE_TEMP_DIR}-<CIRCLE_WORKFLOW_WORKSPACE_ID>` and `release` moves it into live. Workflows that fail before `release` leave their staging folder behind. Consumers (darthjee/pidgey#106) want to run `deploy_frontend.sh cleanup` after `release`. `${SSH_REMOTE_DIR}_old_*` folders are out of scope. Downstream images keep `FROM darthjee/scripts:0.11.0`; bumping them is separate work.

## Steps

- [01 — Create scripts/0.12.0 from 0.11.0](shell/01-create-version-folder.md)
- [02 — Add the cleanup action](shell/02-add-cleanup-action.md)
- [03 — Add cleanup tests](shell/03-add-cleanup-tests.md)
- [04 — Document cleanup in the README](shell/04-document-cleanup.md)
- [05 — Bump scripts in version](shell/05-bump-version.md)

## CI Checks
- `scripts/0.12.0`: `bin/script.sh test scripts` (runs `test/test.sh` inside the built image; CI job `release-scripts` builds and publishes on tags)

## Notes
- The remote host may run GNU or BusyBox `find`; the test image is Alpine (BusyBox). Use only options both support: `-mindepth`, `-maxdepth`, `-type d`, `-name`, `-mmin`, `!`, `-exec ... ';'`.
- Age is the staging folder's own modification time. It changes when entries are added or removed directly inside it, so it is a reasonable proxy for "last touched by a deploy", but not an exact one.
- `-name` takes a glob: if the basename of `SSH_REMOTE_TEMP_DIR` itself contains `*`, `?` or `[`, the match is broader. Document this as a limitation; don't try to escape it.
