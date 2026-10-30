# Update the docs

Update the documentation that describes the description push:

- **`AGENTS.md`:**
  - Line ~104: a missing README now warns and skips instead of failing; login and HTTP errors fail.
  - Line ~121: replace the note that releases don't push descriptions. The CI `release` job now runs `bin/image.sh description <image>` after the image push, and only when `<image>/<version>/` changed since the previous tag. The image push itself ignores README-only changes. READMEs that are already on main but unchanged since the latest tag need a one-off `bin/script.sh push_description <images>`.
- **`docs/agents/image-readme.md`:**
  - Line ~7: mention the automatic push from the release job.
  - Rule 6 ("Family push"): the family push no longer exits 1 on a missing README; it skips with a warning.
- **`docs/agents/architecture.md`** and **`docs/agents/folder-structure.md`:** only adjust the `push_description.sh`/`image.sh` rows if they now read wrong.

## Files to Change

- `AGENTS.md` — description push behaviour and the release-job note.
- `docs/agents/image-readme.md` — automatic push; family push behaviour.
- `docs/agents/architecture.md`, `docs/agents/folder-structure.md` — only if their rows are now inaccurate.
