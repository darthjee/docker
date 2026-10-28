# Plan: Remove the darthjee/heroku image

Issue: [155-remove-the-darthjee-heroku-image.md](../../issues/155-remove-the-darthjee-heroku-image.md)

## Overview

Delete the unused `heroku` tool image and every reference to it — image source, `version` entry, root README, CircleCI release job and project docs — and, since `heroku` is the last image it owns, remove the `tools` agent (definition, check script, roster/author entries) as well, without breaking the `release` workflow for the remaining images.

## Context

`darthjee/heroku` (Heroku CLI on EOL `alpine:3.13.5`) is no longer used, so it is removed instead of getting a README (originally a sub-issue of epic #153), mirroring the `fly` removal in #154 (already merged). There are no `circleci_`/`production_` counterparts and no image builds `FROM darthjee/heroku`. The published image stays on Docker Hub, the Heroku-*platform* layer-limit notes in `README.md`/`docs/agents/architecture.md` stay, and no configuration outside this repo (`~/.claude*`) or the git-ignored `.claude/state/` is touched. Every touched file is root-level, CI, docs or `.claude/`, and the `tools` agent itself is being deleted, so this is one cross-cutting `architect` change.

## Steps

- [01 — Remove the CircleCI release job](plan/01-remove-circleci-release-job.md)
- [02 — Remove the image source, version entry and README entry](plan/02-remove-image-source-and-version.md)
- [03 — Remove the tools agent and heroku from docs](plan/03-remove-tools-agent-and-docs.md)

## CI Checks

- `.circleci/config.yml`: `circleci config validate` (if the CircleCI CLI is available), plus a YAML parse check, e.g. `ruby -ryaml -e 'YAML.load_file(".circleci/config.yml", aliases: true)'` (CI workflow: `release`, tag-only — not exercised by the PR).

## Notes

- Unlike #154 there is no YAML anchor trap: `&tag_only` is defined on `release-scripts`, and no job `requires: [release-heroku]`.
- Final check: `grep -rni "heroku\|check_tools" --exclude-dir=.git . | grep -v "docs/agents/issues\|docs/agents/plans"` should only match the Heroku-platform layer-limit notes (`README.md`, `docs/agents/architecture.md`), and `grep -rnw tools .claude AGENTS.md` should only match the `tools:` frontmatter key of the remaining agents.
- Do not edit `.claude/state/arcanum-config.json` (git-ignored local state) or anything under `~/.claude*`; the `darthjee+infra@gmail.com` author stays, mapped to `shell`.
- Manual follow-up outside the repo (not part of the PR): on any machine where `heroku install` was run, delete `~/.dt-heroku`, its `.bashrc` eval line, and revoke the stored Heroku token.
