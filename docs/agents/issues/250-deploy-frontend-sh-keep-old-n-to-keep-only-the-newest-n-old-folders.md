# Issue: deploy_frontend.sh: KEEP_OLD=<n> to keep only the newest N _old_* folders

## Description
In scripts 0.13.0, `deploy_frontend.sh release` with `KEEP_OLD=true` moves the previous live folder to `${SSH_REMOTE_DIR}_old_<timestamp>` (`<timestamp>` is `date +%s`) and never removes it. `cleanup` explicitly keeps `_old_*` folders (since #249), so they pile up on the host until someone removes them by hand. Raised while refining #248 (the deploy_frontend.sh guide).

## Problem
`KEEP_OLD` is all-or-nothing: either no rollback copy at all, or an unbounded number of them.

## Expected Behavior
In the new scripts version **0.14.0**:
- `KEEP_OLD=<n>` (a positive integer) keeps the `n` newest `${SSH_REMOTE_DIR}_old_<timestamp>` folders; `release` removes the older ones right after the swap.
- `n` counts the folder created by the current release: `KEEP_OLD=1` keeps only the previous live folder.
- `release` prints the name of each `_old_*` folder it prunes.
- `KEEP_OLD=true` keeps its current meaning (keep all), for backward compatibility. Unset, `false` and `0` mean "keep none" (current behaviour).
- Any other value makes `release` fail before touching anything, with an error message (like `CLEANUP_MAX_AGE_MINUTES` in `cleanup`).
- Only folders named `${SSH_REMOTE_DIR}_old_<digits>` are counted and pruned; anything else (e.g. a manually created `_old_backup`) is never touched.

## Solution
1. Create scripts **0.14.0** with `bin/script.sh init scripts` (0.13.0 is already released in tag `1.6.1.3`).
2. In `run_release`, validate `KEEP_OLD` locally, then append a pruning step to the remote command when it is a number:
   - list `${SSH_REMOTE_DIR}_old_*` in the live folder's parent, keep only the ones whose suffix is all digits, sort them numerically by that suffix (not `ls -t` / `find -printf`), and `rm -rf` all but the newest `n`, echoing each removed name;
   - must run on both GNU and BusyBox userland, and quote paths like the rest of the script (paths may contain spaces or quotes).
3. Tests (`test/subtests/release.sh`): command-string test for `KEEP_OLD=<n>`; real-filesystem tests for pruning (more than `n` old folders → only the newest `n` remain, including the one just created), `KEEP_OLD=1`, `KEEP_OLD=0`, non-numeric-suffix folders left alone, invalid value fails without changing anything, and `KEEP_OLD=true` still keeps all.
4. README (0.14.0): update the `release` row, the release steps, the `KEEP_OLD` notes (no more "they pile up") and the `KEEP_OLD` variable row.
5. Guide `docs/agents/deploy_frontend.md`: document `KEEP_OLD=<n>`, add a 0.13.0 → 0.14.0 migration note, and drop the "#250" pointer from the open items.

## Out of scope
A `rollback` action (move live aside to `${SSH_REMOTE_DIR}_failed_<ts>`, then move the newest `_old_*` back). Re-running the previous commit's workflow already works as a rollback, and #248 documents the manual steps; it only becomes safe once a retention policy like this one exists.

## Acceptance criteria
- 0.14.0 `release` with `KEEP_OLD=<n>` leaves at most `n` `_old_<digits>` folders, the newest ones, and prints the pruned names.
- `KEEP_OLD=true`, `false`, unset behave as in 0.13.0; `0` behaves like `false`; invalid values fail before any change.
- Tests cover the cases above; README and guide describe the new behaviour.

## Benefits
- Rollback copies stay available without filling the host disk.
- No manual pruning needed on the remote host.
