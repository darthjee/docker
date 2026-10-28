# Plan: Remove the darthjee/fly image

Issue: [154-remove-the-darthjee-fly-image.md](../../issues/154-remove-the-darthjee-fly-image.md)

## Overview

Delete the unused `fly` tool image and every reference to it — image source, `version` entry, root README, CircleCI release job, project docs, and `.claude/` agent definitions/scripts — without breaking the `release` workflow for the remaining images.

## Context

Concourse is no longer used, so `darthjee/fly` (Concourse `fly` v3.14.1 on EOL `alpine:3.9.4`, amd64-only binary) is removed instead of getting a README (originally a sub-issue of #153). The published `darthjee/fly:0.0.1` stays on Docker Hub (out of scope). Almost all touched files are root-level, CI, or `.claude/` files owned by the `architect`; the `tools` agent's only work would be deleting `fly/`, so the whole change is planned as one cross-cutting architect change rather than split.

## Steps

- [01 — Remove the CircleCI release job safely](plan/01-remove-circleci-release-job.md)
- [02 — Remove the image source and version entry](plan/02-remove-image-source-and-version.md)
- [03 — Remove fly from docs, agents and scripts](plan/03-remove-docs-agents-scripts.md)

## CI Checks

- `.circleci/config.yml`: `circleci config validate` (if the CircleCI CLI is available), plus a YAML parse check, e.g. `ruby -ryaml -e 'YAML.load_file(".circleci/config.yml", aliases: true)'` (CI workflow: `release`, tag-only — not exercised by the PR).
- `heroku`: `.claude/scripts/check_tools.sh` (builds and tests the remaining tool image).

## Notes

- **YAML anchor trap:** `filters: &tag_only` is defined on the `release-fly` job and referenced as `*tag_only` by every other job. It must be moved before `release-fly` is deleted (step 01), or the whole workflow becomes invalid.
- Final check: `grep -rnw fly --exclude-dir=.git .` should only match this issue/plan's own docs (and unrelated uses of the word, if any).
- Older docs/issues/plans under `docs/agents/issues/` and `docs/agents/plans/` that mention `fly` historically are left as-is.
