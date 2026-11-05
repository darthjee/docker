# Tests
In `scripts/0.13.0/test/subtests/cleanup.sh`:

- Update the expected strings of `test_cleanup_command`, `_without_workspace`, `_max_age` and `_trailing_slash`, which now include `! -name 'site' ! -name 'site_old_*'`.
- Add a command test with `SSH_REMOTE_DIR` in a different parent (e.g. `/var/www/site`): no live exclusion is added.
- Add a command test with `SSH_REMOTE_DIR` unset: same command as in 0.12.0.
- Add a command test with a trailing slash on `SSH_REMOTE_DIR` (`/srv/site/`): exclusions use `site`.
- Add a real-execution test (`SSH_STUB_EXEC=1`) for the colliding layout. Use `SSH_REMOTE_TEMP_DIR="$TEST_TMP/ap p"` and `SSH_REMOTE_DIR="$TEST_TMP/ap p-live"`, then use `make_old_folder` to create `ap p-live`, `ap p-live_old_1` and `ap p-old`. Assert that the live and `_old_1` folders survive and `ap p-old` is removed.
- Register the new tests with `run_test`.

## Files to Change
- `scripts/0.13.0/test/subtests/cleanup.sh` — updated and new tests
