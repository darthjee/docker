# Plan: scripts 0.12.0: add a cleanup action to deploy_frontend.sh

Issue: [244-scripts-0-12-0-add-a-cleanup-action-to-deploy-frontend-sh.md](../../issues/244-scripts-0-12-0-add-a-cleanup-action-to-deploy-frontend-sh.md)

## Overview
Create `scripts/0.12.0` from `0.11.0`, add a `cleanup` action to `deploy_frontend.sh` that removes stale `${SSH_REMOTE_TEMP_DIR}-*` staging folders on the remote host, cover it with tests, document it, and bump `scripts` in `version`. All work is in the `scripts` image, owned by the `shell` agent.

See [shell.md](shell.md) for the full plan.
