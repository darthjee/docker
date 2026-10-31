# Add cleanup tests
- `test/helper.sh`: add `CLEANUP_MAX_AGE_MINUTES` to the `unset` list in `setup_env`.
- `test/subtests/actions.sh`: update the expected `Actions:` usage line to end with `release cleanup`.
- New `test/subtests/cleanup.sh`, in the same style as `release.sh`:
  - **Command string** (stubbed ssh): with `CIRCLE_WORKFLOW_WORKSPACE_ID=w1`, assert the exact `ssh_line` (`[ ! -d '/srv' ] || find '/srv' -mindepth 1 -maxdepth 1 -type d -name 'staging-*' -mmin +1440 ! -name 'staging-w1' -exec rm -rf {} ';'`). Without a workspace id there's no `! -name` clause. With `CLEANUP_MAX_AGE_MINUTES=60` it uses `-mmin +60`. With a trailing slash on `SSH_REMOTE_TEMP_DIR`, the result is the same.
  - **Validation**: missing `SSH_REMOTE_TEMP_DIR` / `SSH_USER` → status 1, no remote call. `CLEANUP_MAX_AGE_MINUTES=abc` → status 1, message mentions the variable, no remote call.
  - **Real execution** (`SSH_STUB_EXEC=1`, paths under `$TEST_TMP` that contain a space, as in `setup_real_release`): create `<base>-old` and `<base>-w1` (both aged with `touch -t 200001010000`), `<base>-new` (fresh), the plain `<base>` (aged), the live folder and `<live>_old_1` (aged). Run with `CIRCLE_WORKFLOW_WORKSPACE_ID=w1`. Assert that only `<base>-old` is removed. Also assert that a missing parent folder → status 0.
  - Set the folder's mtime last, after creating any files inside it, so adding the files doesn't reset it.

## Files to Change
- `scripts/0.12.0/test/helper.sh` — unset `CLEANUP_MAX_AGE_MINUTES`.
- `scripts/0.12.0/test/subtests/actions.sh` — usage line includes `cleanup`.
- `scripts/0.12.0/test/subtests/cleanup.sh` — new subtest file.
