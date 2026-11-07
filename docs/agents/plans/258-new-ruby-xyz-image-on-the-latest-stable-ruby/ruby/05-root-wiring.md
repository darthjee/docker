# Root-level wiring (architect)
These files are outside the `ruby` agent's scope, which is limited to the image folders, so the architect does this step.

1. **`version`**: add `ruby_3412=1.0.0` under `# Development`, `circleci_ruby_3412=1.0.0` under `# Circleci`, and `production_ruby_3412=1.0.0` under `# Production`, each next to its `ruby_331` line. Keep the `ruby_331` lines at `1.2.0`.
2. **`.circleci/config.yml`**: add `release-ruby_3412`, `release-circleci_ruby_3412` and `release-production_ruby_3412` jobs, each with `requires: [release-scripts]` and `filters: *tag_only`, right after the matching `release-*ruby_331` job. Don't change any child job's `requires` (that happens in #259–#261).
3. **Root `README.md`**: add the three Docker Hub badge lines next to their `ruby_331` counterparts in the Development, Circleci and Production lists.
4. **`AGENTS.md`**, **`docs/agents/architecture.md`** and **`docs/agents/folder-structure.md`**: list `ruby_3412` (and its counterparts) next to `ruby_331` where images are listed (e.g. the folder-structure table row `ruby_331/, ruby_node/`, and the hierarchy tree with a `ruby:3.4.12` upstream). Leave the generic examples that use `ruby_331` alone.
5. **`.claude/agents/ruby.md`**: extend the scope list to include `ruby_3412`, `circleci_ruby_3412` and `production_ruby_3412`, and update the agent's `description` line.

## Files to Change
- `version` — three new lines.
- `.circleci/config.yml` — three new release jobs.
- `README.md` — three new badges.
- `AGENTS.md`, `docs/agents/architecture.md`, `docs/agents/folder-structure.md` — mention the new image family.
- `.claude/agents/ruby.md` — scope and description include `ruby_3412`.
