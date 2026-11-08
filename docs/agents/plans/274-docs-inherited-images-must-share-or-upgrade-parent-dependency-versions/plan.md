# Plan: docs: inherited images must share or upgrade parent dependency versions

Issue: [274-docs-inherited-images-must-share-or-upgrade-parent-dependency-versions.md](../../issues/274-docs-inherited-images-must-share-or-upgrade-parent-dependency-versions.md)

## Overview
Write down the dependency-version rule for inherited images. The full rule goes in `docs/agents/contributing.md`. `docs/agents/architecture.md` and the specialist agent definitions in `.claude/agents/` get short pointers to it. Only documentation changes; no image changes.

## Context
- Delta copying works by name **and** version. `bundle_builder.sh` copies `gems/<name>-<version>` only when it is missing from the base's bundle; `yarn_builder.sh` does the same with yarn cache entries; `poetry_builder.sh` plays the equivalent role for the django family. So when a child uses any version of a shared dependency other than the parent's, that version is copied as new and the final image carries both copies.
- The rule, for every kind of dependency (gems, npm/yarn, pip/poetry, system packages, …), applies to a child image and its `circleci_`/`production_` counterparts:
  1. A dependency shared with the parent uses **exactly the parent's version**.
  2. An **older** version is never allowed.
  3. A **newer** version is a last resort. First decide which case applies:
     - **The base image needs a new version.** Bump the parent image to a new version and rebase the child onto it.
     - **It is a fix specific to the child.** Pin the newer version in the child, accepting that the parent's copy stays in the image too, and record the reason in the issue/PR (and in the image README where useful).
  4. Lock files (`Gemfile.lock`, `yarn.lock`, `poetry.lock`, …) are seeded from the parent's lock file, so transitive dependencies match too.
- Existing anchors:
  - `docs/agents/contributing.md` § "### One responsibility per image" (line ~52)
  - `docs/agents/architecture.md` line 37: "Each image in a hierarchy installs only the delta relative to its parent…"
  - The "## Conventions" delta bullet in `.claude/agents/ruby.md`, `ruby-node.md`, `node.md` and `python.md`
- The architect owns `docs/agents/` and `.claude/agents/`, so this plan has no specialist split.

## Steps

- [01 — Document the rule in contributing.md](plan/01-contributing-rule.md)
- [02 — Point to it from architecture.md](plan/02-architecture-pointer.md)
- [03 — Add the rule to the specialist agent definitions](plan/03-agent-definitions.md)

## Notes
- This plan touches no image folder, so no `bin/script.sh build/test` run is needed. Check the relative Markdown links by hand: `.claude/agents/*.md` link to `../../docs/agents/contributing.md`; `architecture.md` links to `contributing.md`.
- Use an explicit heading (e.g. `#### Dependency versions in inherited images`) so the agent files and `architecture.md` can link to an anchor.
- Keep the wording general (all dependency types); use gems/yarn only as the concrete example of why the rule holds.
