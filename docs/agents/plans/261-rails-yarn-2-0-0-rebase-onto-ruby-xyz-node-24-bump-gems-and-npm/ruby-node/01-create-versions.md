# Create the 2.0.0 versions
Run `bin/script.sh init rails_yarn 2.0.0`. It copies `1.3.0` → `2.0.0` for `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn`, sets all three to `2.0.0` in `version`, and rewrites `darthjee/*:x.y.z` `FROM` lines to the versions in `version` (so `scripts:0.11.0` becomes `scripts:0.15.0`; the `ruby_331` base is replaced in step 02).

Commit this copy on its own, before any edit, so later diffs show only the real changes.

## Files to Change
- `version` — `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn` → `2.0.0`
- `rails_yarn/2.0.0/`, `circleci_rails_yarn/2.0.0/`, `production_rails_yarn/2.0.0/` — new (copies of `1.3.0`)
