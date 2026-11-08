# Create the 2.0.0 versions
Run `bin/script.sh init ruby_node 2.0.0`. It copies `1.6.0` to `2.0.0` for `ruby_node`, `circleci_ruby_node` and `production_ruby_node`, and updates the three entries in `version`. Commit this on its own (pure copy), so later diffs show only the real changes.

## Files to Change
- `ruby_node/2.0.0/`, `circleci_ruby_node/2.0.0/`, `production_ruby_node/2.0.0/` — new (copied from `1.6.0`)
- `version` — `ruby_node`, `circleci_ruby_node`, `production_ruby_node` → `2.0.0`
