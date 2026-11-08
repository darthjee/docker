# Root wiring (architect)
Outside the `ruby-node` agent's scope — done by the architect.

- `.circleci/config.yml`: `release-ruby_node` → `requires: [release-ruby_3412]`; `release-circleci_ruby_node` → `requires: [release-circleci_ruby_3412]`; `release-production_ruby_node` → `requires: [release-production_ruby_3412]`.
- `.claude/agents/ruby-node.md`: "`ruby_node/` — `ruby_331` + Node" → "`ruby_3412` + Node".
- `docs/agents/architecture.md` hierarchy tree: add `ruby_3412` / `circleci_ruby_3412` / `production_ruby_3412` nodes and move the three `ruby_node` entries under them; keep `ruby_331` for images still built on it. The note that `ruby_node` has no `home/` folder needs no change.

## Files to Change
- `.circleci/config.yml`
- `.claude/agents/ruby-node.md`
- `docs/agents/architecture.md`
