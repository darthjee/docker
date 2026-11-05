# Tests
Extend `scripts/0.14.0/test/subtests/release.sh` (keep every existing test passing unchanged):

- `test_release_command_keep_old_count`: `KEEP_OLD=2`, assert the exact ssh command string (same style as `test_release_command_keep_old`).
- `test_release_invalid_keep_old`: e.g. `KEEP_OLD=yes` and `KEEP_OLD=-1` → status 1, output mentions `KEEP_OLD`, `calls` is empty.
- `test_release_keep_old_zero`: real filesystem (`setup_real_release`), `KEEP_OLD=0` → old folder removed, like `false`.
- `test_release_prunes_old_folders`: real filesystem, pre-create `${SSH_REMOTE_DIR}_old_1600000000`, `_old_1650000000`, `_old_1690000000` plus live and staging, with `DATE_STUB=1700000000` and `KEEP_OLD=2` → only `_old_1700000000` (the previous live, content `old`) and `_old_1690000000` remain. Output contains `Removed old folder:` for 1600000000 and 1650000000.
- `test_release_keep_old_one`: `KEEP_OLD=1` → only `_old_1700000000` remains.
- `test_release_prune_ignores_non_numeric`: an `${SSH_REMOTE_DIR}_old_backup` folder (and e.g. `_old_12a`) survives a prune with `KEEP_OLD=1`.
- `test_release_prune_numeric_order`: suffixes of different lengths (e.g. `_old_999` vs `_old_1600000000`) are ordered numerically, not lexically.
- `test_release_keep_old_true_keeps_all`: with pre-existing old folders and `KEEP_OLD=true`, nothing is removed.
- `test_release_prune_first_deploy`: `KEEP_OLD=2` with no live folder and no old folders → succeeds, nothing printed or removed.

The fixture paths already contain a space (`si te`). Keep at least one prune test on that path.

## Files to Change
- `scripts/0.14.0/test/subtests/release.sh` — new tests listed above
