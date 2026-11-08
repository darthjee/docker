# Root wiring (architect)
Outside the `ruby-node` agent's scope — done by the architect.

- `.circleci/config.yml`: `release-rails_yarn` → `requires: [release-scripts, release-ruby_node]`; `release-circleci_rails_yarn` → `requires: [release-scripts, release-circleci_ruby_node]`; `release-production_rails_yarn` → `requires: [release-scripts, release-production_ruby_node]`.
- `.claude/agents/ruby-node.md`: "`rails_yarn/` — `ruby_331` + Yarn" → "`ruby_node` + Yarn (`1.x` was `ruby_331` + Node + Yarn)"; update the chain example to `taap` ← `taa` ← `rails_yarn` ← `ruby_node` ← `ruby_3412`, and the delta-convention example (`ruby_331`/`rails_yarn` → `ruby_node`/`rails_yarn`).
- `docs/agents/architecture.md` hierarchy tree: add `rails_yarn/` under `ruby_node/`, `circleci_rails_yarn/` under `circleci_ruby_node/`, `production_rails_yarn/` under `production_ruby_node/` (e.g. "← adds Yarn (since 2.0.0)").

## Files to Change
- `.circleci/config.yml`
- `.claude/agents/ruby-node.md`
- `docs/agents/architecture.md`
