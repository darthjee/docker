# README
Edit `scripts/0.13.0/README.md` following `docs/agents/image-readme.md`:

- Actions table, `cleanup` row: replace "It does **not** exclude the live folder…" with: it never removes `SSH_REMOTE_DIR` or the `${SSH_REMOTE_DIR}_old_*` folders when they are in the same parent folder.
- `### Cleanup`: replace the "**Naming rule:**" paragraph with a softened version. State the guarantee (from 0.13.0 a colliding name no longer deletes the live or `_old_*` folders). Keep the separate-parent layout example (`/srv/app/live` + `/srv/app/staging`) as the **recommended** layout because it is clearer, and note that glob characters in `SSH_REMOTE_DIR`'s basename can widen the exclusion.
- `KEEP_OLD` notes in `### Failure and recovery`: drop "(as long as their names follow the naming rule)".
- Update any other 0.12.0 version mention that refers to the current version.

## Files to Change
- `scripts/0.13.0/README.md` — cleanup docs
