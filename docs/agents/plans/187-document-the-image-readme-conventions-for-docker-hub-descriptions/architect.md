# Plan: Document the image README conventions for Docker Hub descriptions

Issue: [187-document-the-image-readme-conventions-for-docker-hub-descriptions.md](../../issues/187-document-the-image-readme-conventions-for-docker-hub-descriptions.md)

## Overview
Write the README spec `docs/agents/image-readme.md` from the rules settled in #156–#162 (all listed in the issue's Solution), then link it from `AGENTS.md`, `.claude/agents/*.md` and `docs/agents/issue-enhancement.md`, fixing the stale `AGENTS.md` statements and the `cimg` inaccuracy in `python.md` along the way.

## Context
- 21 existing READMEs share one skeleton (title, *About the image*, middle sections, *How to use*, *License*); none is rewritten.
- `bin/push_description.sh` pushes a family's READMEs and exits 1 on the first missing one; CI does not push descriptions yet (#171).
- No image, `version`, Dockerfile or README change; no GitHub issue edits (those are a manual post-merge follow-up, outside this plan).

## Steps

- [01 — Write the README spec](architect/01-write-readme-spec.md)
- [02 — Update AGENTS.md](architect/02-update-agents-md.md)
- [03 — Wire the spec into agent files and issue-enhancement.md](architect/03-wire-agent-files.md)

## Notes
- README-only and docs-only changes need no `bin/script.sh pre_build`/`build`/`test`.
- Verify by hand that every relative link added resolves from its file's location (`AGENTS.md` at the root uses `docs/agents/image-readme.md`; `.claude/agents/*.md` use `../../docs/agents/image-readme.md`; files inside `docs/agents/` use `image-readme.md`).
- Post-merge (not in this PR): edit Epic #153 and #163–#170 to point at the spec, widen #173 to parent versions, comment on #171.
