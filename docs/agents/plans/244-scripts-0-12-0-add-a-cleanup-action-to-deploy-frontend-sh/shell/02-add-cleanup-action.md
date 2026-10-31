# Add the cleanup action
In `scripts/0.12.0/home/sbin/deploy_frontend.sh`:

- Add `cleanup` to the header comment's `Actions:` list and to `ACTIONS` (after `release`), and a `"cleanup") run_cleanup ;;` branch in `main`.
- Add `run_cleanup`:
  - `require_ssh`, `require_temp_dir`.
  - `CLEANUP_MAX_AGE_MINUTES` defaults to `1440`. If it is not a non-negative integer (`^[0-9]+$`), print `CLEANUP_MAX_AGE_MINUTES must be a number of minutes` to stderr and return `1` before any remote call.
  - Strip the trailing slash from `SSH_REMOTE_TEMP_DIR` (`${SSH_REMOTE_TEMP_DIR%/}`, like `workspace_temp_dir`), then split it into `parent=$(dirname …)` and `base=$(basename …)`.
  - Build one remote command, with every path and pattern passed through `quote`:

    ```sh
    [ ! -d '<parent>' ] || find '<parent>' -mindepth 1 -maxdepth 1 -type d -name '<base>-*' -mmin +<age> [! -name '<base>-<workspace id>'] -exec rm -rf {} ';'
    ```

    The `! -name …` exclusion is added only when `CIRCLE_WORKFLOW_WORKSPACE_ID` is set. A missing parent folder means there is nothing to clean, so it exits `0`. `-name '<base>-*'` never matches the plain `<base>` folder or the live folder (unless the live folder is itself named `<base>-…`, which is a misconfiguration).
  - Send it with `remote`. A failing `find`/`rm` makes the action fail (`set -euo pipefail` + ssh exit status).

## Files to Change
- `scripts/0.12.0/home/sbin/deploy_frontend.sh` — new `run_cleanup` function, `cleanup` in `ACTIONS`, the header comment and `main`.
