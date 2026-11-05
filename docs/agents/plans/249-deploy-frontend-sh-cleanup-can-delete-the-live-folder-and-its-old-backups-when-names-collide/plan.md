# Plan: deploy_frontend.sh cleanup can delete the live folder and its _old_* backups when names collide

Issue: [249-deploy-frontend-sh-cleanup-can-delete-the-live-folder-and-its-old-backups-when-names-collide.md](../../issues/249-deploy-frontend-sh-cleanup-can-delete-the-live-folder-and-its-old-backups-when-names-collide.md)

## Overview
Release scripts **0.13.0**, whose `deploy_frontend.sh cleanup` excludes `SSH_REMOTE_DIR` and `${SSH_REMOTE_DIR}_old_*` when they share the staging folder's parent. Add tests for the colliding layout and update the 0.13.0 README. The scripts work belongs to the `shell` agent.

See [shell.md](shell.md) for the full plan.

## Architect follow-up (outside `scripts/`)
The `shell` agent may not touch files outside `scripts/`, so the architect updates the guide `docs/agents/deploy_frontend.md` after the shell steps land:

- `## Versions`: add "0.12.0 → 0.13.0: `cleanup` now never removes `SSH_REMOTE_DIR` / `${SSH_REMOTE_DIR}_old_*` in the same parent folder; no breaking changes."
- `## Reference` and the migration section: point to 0.13.0 as the current version where they name the latest version. Add a short 0.12.0 → 0.13.0 migration note: upgrade to drop the naming-rule workaround, or keep the separate-parent layout as the recommended one.
- `### Migration checklist` item 6: rewrite it as a recommendation, saying that from 0.13.0 the collision no longer deletes the folders (on 0.12.0 it is still required).
- `## Out of scope here`: drop the #249 mention, keep #250.
