# Remove the tools agent and heroku from docs

With `heroku` gone, the `tools` agent owns nothing, so remove it and every reference to it and to `heroku/`:

- `git rm .claude/agents/tools.md .claude/scripts/check_tools.sh`.
- `.claude/agents/architect.md`: remove the `` | `tools` | `heroku/` — standalone utility image | `` row from the agent roster table.
- `.claude/agents/shell.md`: "Do NOT touch `heroku/` (owned by the `tools` agent), any language-specific image family, `bin/`, or any file outside `scripts/`." → "Do NOT touch any language-specific image family, `bin/`, or any file outside `scripts/`."
- `.claude/configuration/arcanum-repo-config.json`: remove the `"tools": "darthjee+infra@gmail.com"` entry from `git.agents` (fix the trailing comma on the preceding `shell` entry so the JSON stays valid). Do not touch `.claude/state/` or any `~/.claude*` file.
- `AGENTS.md`:
  - Image categories: `Utility images (e.g. `scripts`, `heroku`)` → `Utility images (e.g. `scripts`)`.
  - Folder tree: drop the `├── heroku/                  # heroku tool image source` line (adjust the tree connector of the neighbouring line if `heroku/` was the last entry of its level).
- `docs/agents/folder-structure.md`: drop the `` | `heroku/` | Source for the `heroku` tool image. | `` row.

Keep the Heroku-platform layer-limit note in `docs/agents/architecture.md`. Finish with the greps from the plan's Notes and a JSON parse of the repo config (e.g. `jq . .claude/configuration/arcanum-repo-config.json`).

## Files to Change
- `.claude/agents/tools.md` — delete.
- `.claude/scripts/check_tools.sh` — delete.
- `.claude/agents/architect.md` — remove the `tools` roster row.
- `.claude/agents/shell.md` — drop the `heroku/`/`tools` "do not touch" reference.
- `.claude/configuration/arcanum-repo-config.json` — remove the `tools` key from `git.agents`.
- `AGENTS.md` — remove `heroku` from the categories example and folder tree.
- `docs/agents/folder-structure.md` — remove the `heroku/` row.
