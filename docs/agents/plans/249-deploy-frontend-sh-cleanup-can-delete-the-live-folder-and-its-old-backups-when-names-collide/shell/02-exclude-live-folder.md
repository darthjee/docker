# Exclude the live folder in run_cleanup
In `run_cleanup` in `scripts/0.13.0/home/sbin/deploy_frontend.sh`, after the workspace exclusion and before `-exec`:

- If `SSH_REMOTE_DIR` is set and non-empty, strip its trailing slashes the same way `dir` is stripped. Compute `live_parent=$(dirname ...)` and `live_base=$(basename ...)`.
- If `live_parent` equals the (unquoted) parent of the staging dir, append:
  `! -name $(quote "$live_base") ! -name $(quote "${live_base}_old_*")`
- Otherwise add nothing: a folder in a different parent can never match.

`SSH_REMOTE_DIR` stays optional for `cleanup`: do not call `require_remote_dir`. Only use `find` primaries that exist in both GNU and BusyBox `find` (`! -name` already does). Update the comment above the function to say it also keeps the live folder and its `_old_*` folders.

Expected command for the helper defaults with `CIRCLE_WORKFLOW_WORKSPACE_ID=w1`:
`[ ! -d '/srv' ] || find '/srv' -mindepth 1 -maxdepth 1 -type d -name 'staging-*' -mmin +1440 ! -name 'staging-w1' ! -name 'site' ! -name 'site_old_*' -exec rm -rf {} ';'`

## Files to Change
- `scripts/0.13.0/home/sbin/deploy_frontend.sh` — `run_cleanup` exclusions
