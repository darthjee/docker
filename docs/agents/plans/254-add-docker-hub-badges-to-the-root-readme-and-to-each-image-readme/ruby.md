# Ruby Plan: Add Docker Hub badges to the root README and to each image README

Main plan: [plan.md](plan.md)

## Shared contracts

Use the badge markdown and placement from [plan.md → Shared contracts](plan.md#shared-contracts) exactly, with `<image>` the image name:

```markdown
[![docker](https://img.shields.io/docker/v/darthjee/<image>.svg?logo=docker&label=<image>&sort=semver)](https://hub.docker.com/r/darthjee/<image>)
```

Placement: right after the `=` underline of the `darthjee/<image>` title, with a blank line before and after it, before `## About the image`.

## Implementation Steps

### Step 1 — Add the badge to each image README

For each image below, edit only the README in the folder the root `version` file points to, and add the badge under the title. Change nothing else in the README: no other cleanup, and no edits to older version folders. This is a README-only change: no `bin/script.sh init`, no `version` bump, no build or test run.

## Files to Change
- `ruby_331/1.2.0/README.md` — badge for `darthjee/ruby_331` under the title.
- `rails_gems/2.2.0/README.md` — badge for `darthjee/rails_gems` under the title.
- `circleci_ruby_331/1.2.0/README.md` — badge for `darthjee/circleci_ruby_331` under the title.
- `circleci_rails_gems/2.2.0/README.md` — badge for `darthjee/circleci_rails_gems` under the title.
- `production_ruby_331/1.2.0/README.md` — badge for `darthjee/production_ruby_331` under the title.

## Notes
- Follow [docs/agents/image-readme.md](../../image-readme.md). Its skeleton is updated in the same PR by the architect to include this badge.
