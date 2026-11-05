# Plan: Write a guide for deploy_frontend.sh (actions, variables, 0.9.0 → 0.12.0 migration)

Issue: [248-write-a-guide-for-deploy-frontend-sh-actions-variables-0-9-0-0-12-0-migration.md](../../issues/248-write-a-guide-for-deploy-frontend-sh-actions-variables-0-9-0-0-12-0-migration.md)

## Overview

Docs only, no new image version. Complete the existing `deploy_frontend.sh` reference in `scripts/0.12.0/README.md`: an "Operates on" column, failure and recovery, edge cases, the corrected `cleanup` claim, and `cleanup` in its own CircleCI job. Add `docs/agents/deploy_frontend.md` with the verified 0.9.0/0.10.0 → 0.12.0 migration table and checklist, pointing to the README. Link it from `AGENTS.md`.

See [shell.md](shell.md) for the full plan.
