# Architect Plan: Add Docker Hub badges to the root README and to each image README

Main plan: [plan.md](plan.md)

## Shared contracts

Produces the root README badges, which must use the badge markdown from [plan.md → Shared contracts](plan.md#shared-contracts) exactly:

```markdown
[![docker](https://img.shields.io/docker/v/darthjee/<image>.svg?logo=docker&label=<image>&sort=semver)](https://hub.docker.com/r/darthjee/<image>)
```

`bin/archive.sh` relies on each root README line containing `(https://hub.docker.com/r/darthjee/<image>)`. The `docs/agents/image-readme.md` rule must describe the same badge and placement the specialists apply.

## Steps

- [01 — Root README badges](architect/01-root-readme-badges.md)
- [02 — Image README spec](architect/02-image-readme-spec.md)
- [03 — archive.sh badge matching](architect/03-archive-badge-matching.md)

## Notes

- Write the PR description, including the post-merge `bin/script.sh push_description` commands from [plan.md → Notes](plan.md#notes).
- Leave the Codacy badge and the rest of the root README unchanged.
