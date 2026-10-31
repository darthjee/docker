# Document cleanup in the README
In `scripts/0.12.0/README.md`:

- Actions table: add a `cleanup` row that says it removes `${SSH_REMOTE_TEMP_DIR}-*` folders older than `CLEANUP_MAX_AGE_MINUTES`, and never removes the current workspace folder, the plain `SSH_REMOTE_TEMP_DIR`, the live folder or `_old_*` folders.
- Variables table: add `CLEANUP_MAX_AGE_MINUTES` (not required, default `1440`, used by `cleanup`). Mark `SSH_REMOTE_TEMP_DIR` as also required for `cleanup` if the wording needs it.
- CircleCI example: add `- run: deploy_frontend.sh cleanup` after `deploy_frontend.sh release` in the `release` job.
- Mention the `-name` glob limitation (a basename containing `*`, `?` or `[`).
- Replace any `0.11.0` references in usage examples with `0.12.0`.

## Files to Change
- `scripts/0.12.0/README.md` — cleanup action, variable, CircleCI example, version references.
