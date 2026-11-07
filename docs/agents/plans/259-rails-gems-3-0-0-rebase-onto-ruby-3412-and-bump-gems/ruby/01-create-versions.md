# Create the 3.0.0 versions
Run `bin/script.sh init rails_gems 3.0.0`. It copies `rails_gems/2.2.0` and `circleci_rails_gems/2.2.0` to `3.0.0` (there is no `production_rails_gems`, so that iteration is a no-op) and updates the `version` file. Verify `version` now reads `rails_gems=3.0.0` and `circleci_rails_gems=3.0.0`, and that `2.2.0` is untouched. Commit this pure copy on its own so later diffs show only the real changes.

## Files to Change
- `rails_gems/3.0.0/` — new, copied from `2.2.0`
- `circleci_rails_gems/3.0.0/` — new, copied from `2.2.0`
- `version` — `rails_gems=3.0.0`, `circleci_rails_gems=3.0.0`
