# Shell Plan: deploy_frontend.sh cleanup can delete the live folder and its _old_* backups when names collide

Main plan: [plan.md](plan.md)

## Overview
Create scripts 0.13.0. Make `run_cleanup` skip the live folder and its `_old_*` backups when they sit in the same parent folder as the staging folders. Cover this with tests and update the README.

## Context
`run_cleanup` (`scripts/0.12.0/home/sbin/deploy_frontend.sh`) runs
`find <parent> -mindepth 1 -maxdepth 1 -type d -name '<base>-*' -mmin +<age> [! -name '<base>-<ws>'] -exec rm -rf {} ';'`
and has no exclusion for `SSH_REMOTE_DIR`. With `SSH_REMOTE_TEMP_DIR=/var/www/app` and `SSH_REMOTE_DIR=/var/www/app-live`, both `app-live` and `app-live_old_*` match `app-*` and get deleted.

## Steps

- [01 — Create scripts 0.13.0](shell/01-create-version.md)
- [02 — Exclude the live folder in run_cleanup](shell/02-exclude-live-folder.md)
- [03 — Tests](shell/03-tests.md)
- [04 — README](shell/04-readme.md)

## CI Checks
- `scripts`: `bin/script.sh pre_build scripts && bin/script.sh build scripts && bin/script.sh test scripts`

## Notes
- The test helper's default `SSH_REMOTE_DIR=/srv/site` shares the parent `/srv` with `SSH_REMOTE_TEMP_DIR=/srv/staging`, so the expected command strings of the existing command tests change.
- `-name` takes a glob: a live basename with `*`, `?` or `[` may exclude more folders than intended. Excluding too much is the safe direction; mention it in the README next to the existing glob caveat.
- Do not touch `scripts/0.12.0`.
