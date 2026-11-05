# Plan: deploy_frontend.sh: KEEP_OLD=<n> to keep only the newest N _old_* folders

Issue: [250-deploy-frontend-sh-keep-old-n-to-keep-only-the-newest-n-old-folders.md](../../issues/250-deploy-frontend-sh-keep-old-n-to-keep-only-the-newest-n-old-folders.md)

## Overview
Add a bounded retention mode to `deploy_frontend.sh release` in a new scripts **0.14.0** (0.13.0 is already released in tag `1.6.1.3`): `KEEP_OLD=<n>` keeps the `n` newest `${SSH_REMOTE_DIR}_old_<digits>` folders, counting the one created by the current release, and prunes the older ones, printing each removed name. The shell agent changes the script, tests and README. The architect updates the agent guide.

## Agents involved

- [shell](shell.md)
- [architect](architect.md)

## Shared contracts

`KEEP_OLD` semantics in 0.14.0 (the README, the tests and the guide must all say the same thing):

| Value | Behaviour |
|---|---|
| unset, `false`, `0` | keep none: `release` removes `<old>` after the swap (same as 0.13.0) |
| `true` | keep all: no pruning (same as 0.13.0) |
| positive integer `n` (`[0-9]+`, > 0) | keep the `n` newest `${SSH_REMOTE_DIR}_old_<digits>` folders, **including** the one this release just created; remove the rest after the swap, printing one line per removed folder |
| anything else | `release` fails **before any remote call**, exit 1, message on stderr naming `KEEP_OLD` |

- Only folders whose name is exactly `<basename of SSH_REMOTE_DIR>_old_` followed by digits only are counted and pruned. Other `_old_*` names are never touched.
- Order is the numeric value of the suffix (a `date +%s` timestamp), not mtime.
- Printed line format: `Removed old folder: <full path>` (one per pruned folder, on stdout).
- Pruning is a new last step of the `release` `&&` chain: if it fails, the deploy already succeeded (same as step 4 failing today).
- The version is `0.14.0` (root `version` file: `scripts=0.14.0`).
