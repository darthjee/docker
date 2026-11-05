# Shell Plan: Write a guide for deploy_frontend.sh (actions, variables, 0.9.0 → 0.12.0 migration)

Main plan: [plan.md](plan.md)

## Overview

The `scripts` image owns `deploy_frontend.sh` and its README, so the shell specialist owns this issue end to end. That includes the agent-facing `docs/agents/deploy_frontend.md` and the `AGENTS.md` row: they document the scripts image and contain no cross-cutting decision. All content to write is already specified, and verified against the 0.9.0 and 0.12.0 sources, in the issue file. The steps below say where each part goes and what to check.

## Context

- `scripts/0.12.0/README.md` (section `## deploy_frontend.sh`) already covers actions, variables with defaults, the workspace- vs. target-folder model, runtime requirements and a CircleCI example. Do **not** duplicate it in `docs/agents/`.
- The script source of truth is `scripts/0.12.0/home/sbin/deploy_frontend.sh`. 0.9.0's is `scripts/0.9.0/home/sbin/deploy_frontend.sh`; 0.10.0's is byte-identical to 0.9.0's, and 0.11.0 → 0.12.0 only adds `cleanup`.
- READMEs follow [Image READMEs](../../image-readme.md).
- Code changes are out of scope: the `cleanup` name-collision bug is #249, `KEEP_OLD=<n>` is #250.

## Steps

- [01 — README: "Operates on" column and failure/recovery section](shell/01-readme-failure-recovery.md)
- [02 — README: edge cases, gotchas and the CircleCI example](shell/02-readme-edge-cases.md)
- [03 — Agent doc: docs/agents/deploy_frontend.md](shell/03-agent-doc.md)
- [04 — Link the agent doc from AGENTS.md](shell/04-agents-md-link.md)

## CI Checks

- No CI job runs on branches: `.circleci/config.yml` only runs on tags. On the next tag, `release-scripts` runs `bin/image.sh description scripts`, which pushes the README to Docker Hub because `scripts/0.12.0/` changed. The image push itself ignores `README.md`.
- The script is unchanged, so no script tests need to run. Optionally run `bin/script.sh test scripts` as a sanity check.

## Notes

- Every behaviour claim must be checkable against the 0.12.0 (or 0.9.0) source. Re-read the relevant function before writing each claim; do not copy the issue's wording blindly where the source says otherwise.
- The `CIRCLE_WORKFLOW_WORKSPACE_ID` rerun-from-failed behaviour (same id kept) must be confirmed against CircleCI's documentation and cited with a link in the README. If it can't be confirmed, word the `cleanup`-in-its-own-job advice without relying on it, and flag it in the PR description.
- Placeholders only in examples: no real hosts, users or keys.
