# Issue: scripts 0.12.0: add a cleanup action to deploy_frontend.sh

## Description

Add a `cleanup` action to `deploy_frontend.sh` and release it as `darthjee/scripts:0.12.0`. Requested by darthjee/pidgey#106.

## Problem

Since `0.11.0`, each workflow uploads into its own staging folder, `${SSH_REMOTE_TEMP_DIR}-<CIRCLE_WORKFLOW_WORKSPACE_ID>`, and `release` swaps that folder into live. A workflow that fails before `release` leaves its staging folder on the server, and nothing removes it. Consumers such as Pidgey currently clean these up by hand.

## Expected Behavior

`deploy_frontend.sh cleanup`, run on the remote host over SSH like the other actions:

- requires `SSH_USER`, `SSH_HOST` and `SSH_REMOTE_TEMP_DIR`;
- removes the `${SSH_REMOTE_TEMP_DIR}-*` staging folders (direct matches only, e.g. `find -maxdepth 1`) whose modification time is older than `CLEANUP_MAX_AGE_MINUTES` (default `1440`, one day);
- keeps more recent staging folders, since they may belong to a deploy that is still running;
- never touches the live folder (`SSH_REMOTE_DIR`), the plain unsuffixed `SSH_REMOTE_TEMP_DIR`, or the current workflow's staging folder (when `CIRCLE_WORKFLOW_WORKSPACE_ID` is set);
- still works when `CIRCLE_WORKFLOW_WORKSPACE_ID` is unset (it just has no current staging folder to exclude);
- quotes paths and fails fast, like the other `0.11.0` actions, and is listed in the usage `Actions:`.

Out of scope: the `${SSH_REMOTE_DIR}_old_*` folders left by `release` with `KEEP_OLD=true`.

## Solution

- Add `scripts/0.12.0` copied from `0.11.0`, with the new `cleanup` action, test subtests covering it, and README documentation (action and `CLEANUP_MAX_AGE_MINUTES`).
- Bump `scripts=0.12.0` in `version` so `darthjee/scripts:0.12.0` is published.
- Downstream images that build `FROM darthjee/scripts:0.11.0` are not bumped here; they get separate issues.
- Owner: the `shell` agent.

## Benefits

Consumers can add `deploy_frontend.sh cleanup` as the last step of their release job, after `release`, and drop the manual cleanup.
