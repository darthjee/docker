# Issue: deploy_frontend.sh cleanup can delete the live folder and its _old_* backups when names collide

## Description
In scripts 0.12.0, `deploy_frontend.sh cleanup` runs this on the remote host:

```
find <parent of SSH_REMOTE_TEMP_DIR> -mindepth 1 -maxdepth 1 -type d -name '<basename>-*' -mmin +<age> [! -name '<basename>-<workspace id>'] -exec rm -rf {} ';'
```

It has no exclusion for `SSH_REMOTE_DIR` or for the `${SSH_REMOTE_DIR}_old_*` folders that `release` keeps when `KEEP_OLD=true`. Found while refining #248 (the deploy_frontend.sh guide).

## Problem
When the live folder sits next to the staging folders and its name matches the staging pattern, `cleanup` deletes it. Example: `SSH_REMOTE_TEMP_DIR=/var/www/app`, `SSH_REMOTE_DIR=/var/www/app-live`:

- Every `app-live_old_<ts>` matches `app-*`. These folders are old by definition, so the rollback copies kept by `KEEP_OLD=true` are silently deleted.
- `app-live` itself matches. It is removed once its modification time is older than `CLEANUP_MAX_AGE_MINUTES`, for example when `cleanup` runs outside a deploy, or when an upload took longer than the max age.

The 0.12.0 README works around this with a "Naming rule" (the live folder **must not** match `<basename>-*`). The test `test_cleanup_removes_old_staging_folders` only passes because its fixture uses non-colliding names (`stag ing` vs `si te`).

## Expected Behavior
- In the new scripts version **0.13.0**, `cleanup` never removes `SSH_REMOTE_DIR` or `${SSH_REMOTE_DIR}_old_*`, even when their names match `<basename of SSH_REMOTE_TEMP_DIR>-*`.
- `SSH_REMOTE_DIR` stays optional for `cleanup`. When it is unset, the behaviour is unchanged.

## Solution
1. Create scripts **0.13.0** with `bin/script.sh init scripts` (from 0.12.0).
2. In `run_cleanup`, when `SSH_REMOTE_DIR` is set and its parent folder (trailing slashes ignored) equals the parent of `SSH_REMOTE_TEMP_DIR`, add to the `find`:
   - `! -name '<basename of SSH_REMOTE_DIR>'`
   - `! -name '<basename of SSH_REMOTE_DIR>_old_*'`

   When `SSH_REMOTE_DIR` lives in a different parent folder, add no exclusion: it cannot match.
   Keep the command compatible with both GNU and BusyBox `find`, and quote the names as the other arguments are quoted.
3. Tests: add a test for the colliding layout (e.g. `.../app` + `.../app-live` + `.../app-live_old_1`, all older than the max age) that checks the live and `_old_*` folders survive while old staging folders are removed. Add a test where `SSH_REMOTE_DIR` is in a different parent folder.
4. README (0.13.0):
   - Update the `cleanup` row in the actions table: it now never removes the live folder or the `${SSH_REMOTE_DIR}_old_*` folders.
   - Soften the "Naming rule" in `### Cleanup`: state the new guarantee, but keep the separate-parent layout (`/srv/app/live` + `/srv/app/staging`) as a **recommendation** (it is clearer), not a requirement.
   - Fix the related statements (e.g. the `KEEP_OLD` note about `_old_*` folders "as long as their names follow the naming rule").
5. Guide `docs/agents/deploy_frontend.md` (from #248): document the 0.13.0 cleanup behaviour, the softened naming rule, and add a 0.12.0 → 0.13.0 migration note.

## Acceptance criteria
- 0.13.0 `cleanup` never removes `SSH_REMOTE_DIR` or `${SSH_REMOTE_DIR}_old_*` when they share the staging parent folder.
- Tests cover the colliding layout and the different-parent layout.
- The 0.13.0 README and `docs/agents/deploy_frontend.md` describe the new behaviour, with the naming rule kept as a recommendation.

Related: #248.

## Benefits
- Rollback copies and the live site can no longer be deleted by a naming collision.
- The documented guarantee matches the real behaviour.
