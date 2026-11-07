# Root wiring (architect)
Outside the `ruby` agent's scope — done by the architect.

- `.circleci/config.yml`: `release-rails_gems` → `requires: [release-scripts, release-ruby_3412]`; `release-circleci_rails_gems` → `requires: [release-scripts, release-circleci_ruby_3412]`.
- `.claude/agents/ruby.md`: `rails_gems/` is now "built on `ruby_3412`" (line describing the image).
- Root `README.md` badges already exist for both images — no change. `AGENTS.md` and `docs/agents/folder-structure.md` need no change.

## Files to Change
- `.circleci/config.yml`
- `.claude/agents/ruby.md`
