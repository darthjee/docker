# Rewrite deploy_frontend.sh

Rewrite `scripts/0.11.0/home/sbin/deploy_frontend.sh` per the issue's Expected Behavior and
Solution sections (Solution wins where they differ). Keep the script name, the `case "$ACTION"`
dispatcher and the existing env vars.

- `#!/bin/bash` + `set -euo pipefail`; optional vars read as `${VAR:-}`; required vars per action
  read with `${VAR:?message}`; `SSH_PORT` defaults to `22`.
- Helpers:
  - `quote` — POSIX single-quote: wrap in `'...'`, turn inner `'` into `'\''`.
  - `workspace_temp_dir` — `${SSH_REMOTE_TEMP_DIR%/}-$CIRCLE_WORKFLOW_WORKSPACE_ID` when the id is
    set, else `$SSH_REMOTE_TEMP_DIR`.
  - `remote_temp_dir` — `workspace_temp_dir` plus `/$DEPLOY_PATH` when set.
  - `ssh_options` / `remote` — one place that builds `ssh -i ~/ssh_key -p $SSH_PORT` plus either
    `-o StrictHostKeyChecking=yes -o UserKnownHostsFile=~/ssh_known_hosts` (when
    `SSH_KNOWN_HOSTS` is set) or `-o StrictHostKeyChecking=no`; `remote "<cmd>"` runs
    `ssh ... "$SSH_USER@$SSH_HOST" "<cmd>"`. Used for rsync's `-e` too.
- Actions:
  - `generate_key_file` — `printf '%s\n' "${SSH_PRIVATE_KEY//\\n/$'\n'}" > ~/ssh_key`, `chmod 600`;
    when `SSH_KNOWN_HOSTS` is set, write it the same way to `~/ssh_known_hosts`.
  - `build` — `${BUILD_COMMAND:-npm run build}`; the `assets/images/` rsync and `*.pbm` cleanup
    only when `assets/images/` exists (use `find ... -delete`, not `rm $(find ...)`).
  - `generate_folder` — `mkdir -p <remote_temp_dir>`.
  - `copy_files` — `cp -R <SSH_REMOTE_DIR/TARGET> <remote_temp_dir>/`, quoted.
  - `upload` — `mkdir -p` the remote dir first, then `rsync -avz -e "<ssh>"`
    [`--exclude-from="$EXCLUDE_FROM"`] `"$SOURCE" "$SSH_USER@$SSH_HOST:<remote_temp_dir>"`.
  - `link` — with `DEPLOY_PATH`: `mkdir -p <dirname> && ln -sfn <SOURCE> <remote_temp_dir>`; with
    no `DEPLOY_PATH` but `TARGET`: `ln -sfn <SOURCE> <TARGET>`; neither → error, exit 1.
  - `run` — `cd <remote_temp_dir> && $COMMAND` (COMMAND passed as is); exit status propagated.
  - `release` — on `workspace_temp_dir`, with `OLD="${SSH_REMOTE_DIR}_old_$(date +%s)"`:
    `test -d STAGING && { [ ! -e LIVE ] || { rm -rf OLD && mv LIVE OLD; }; } && mv STAGING LIVE`
    followed by `&& rm -rf OLD` unless `KEEP_OLD=true`.
  - unknown/missing action — print the action list to stderr, exit 1.
- Strip a trailing `/` from `DEPLOY_PATH` before `ln`/`dirname` (e.g. `public/admin/`), so the
  link path and its parent are right.
- Keep the remote/ssh/rsync calls in small functions so the tests can source or stub them.

## Files to Change
- `scripts/0.11.0/home/sbin/deploy_frontend.sh` — full rewrite.
