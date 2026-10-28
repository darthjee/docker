# Remove fly from docs, agents and scripts

Update the project docs and Claude configuration so nothing refers to the `fly` image anymore:

- `AGENTS.md`:
  - Image categories: `Utility images (e.g. `fly`, `scripts`, `heroku`)` → `(e.g. `scripts`, `heroku`)`.
  - `version` file snippet: drop the `fly=0.0.1` line.
  - Folder tree: drop the `├── fly/                     # fly tool image source` line.
- `docs/agents/folder-structure.md`: drop the `| `fly/` | Source for the `fly` tool image. |` row.
- `.claude/agents/tools.md`:
  - `description`: "Use for any task involving the heroku utility image."
  - Scope: drop the `fly/` bullet; reword "any file outside these two directories" → "any file outside `heroku/`".
- `.claude/agents/architect.md`: the `tools` roster row becomes `` `heroku/` — standalone utility image ``.
- `.claude/agents/shell.md`: "Do NOT touch `fly/`/`heroku/`" → "Do NOT touch `heroku/`".
- `.claude/scripts/check_tools.sh`: `for image in fly heroku; do` → `for image in heroku; do`.

Finish with `grep -rnw fly --exclude-dir=.git .`: only this issue/plan and historical docs under `docs/agents/issues|plans/` may still match. Run `.claude/scripts/check_tools.sh` to confirm `heroku` still builds and tests.

## Files to Change
- `AGENTS.md` — remove `fly` from the categories example, version snippet and folder tree.
- `docs/agents/folder-structure.md` — remove the `fly/` row.
- `.claude/agents/tools.md` — scope down to `heroku` only.
- `.claude/agents/architect.md` — update the `tools` roster row.
- `.claude/agents/shell.md` — update the "do not touch" list.
- `.claude/scripts/check_tools.sh` — loop over `heroku` only.
