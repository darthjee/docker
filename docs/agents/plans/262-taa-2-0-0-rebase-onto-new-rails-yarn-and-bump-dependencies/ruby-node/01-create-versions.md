# Create the 2.0.0 versions
Run `bin/script.sh init taa 2.0.0` (it copies the current version folder for `taa`, `circleci_taa` and `production_taa`, updates the `version` file, and rewrites `darthjee/*:x` `FROM` lines to the versions in `version`, so `scripts` and `rails_yarn` move to `0.15.0` / `2.0.0`). Verify the three `FROM` lines afterwards. Commit this copy on its own, before any edits, so later diffs show only real changes.

## Files to Change
- `version` — `taa`, `circleci_taa`, `production_taa` → `2.0.0`
- `taa/2.0.0/`, `circleci_taa/2.0.0/`, `production_taa/2.0.0/` — new folders copied from `1.7.0`
