# Ruby Plan: Republish the Ruby image chain (ruby_331 → ruby_node / rails_yarn / rails_gems → taa) as multi-arch

Main plan: [plan.md](plan.md)

## Shared contracts

Produce `ruby_331`, `circleci_ruby_331`, `production_ruby_331` `1.2.0` on `darthjee/scripts:0.11.0`, recorded in the `version` file, before `ruby-node` starts. Build all three locally so `ruby-node` can build on them.

## Implementation Steps

### Step 1 — `ruby_331` 1.2.0 (all variants)
Run `bin/script.sh init ruby_331 1.2.0`. This copies `ruby_331/1.1.1`, `circleci_ruby_331/1.1.1` and `production_ruby_331/1.1.1` to `1.2.0`, updates the `version` file, and rewrites `FROM darthjee/scripts:0.7.0` to `0.11.0`. Check that every script these Dockerfiles copy or source from the `scripts` stage still exists with the same path and behavior in `scripts:0.11.0` (compare `scripts/0.7.0` with `scripts/0.11.0`), and update the Dockerfiles if not. Update the copied READMEs to the new version. Build and test with `bin/script.sh build ruby_331 circleci_ruby_331 production_ruby_331` and `bin/script.sh test ...`. Then check arm64 with `docker buildx build --platform linux/arm64` for each variant (`ruby:3.3.1` and `cimg/ruby:3.3.1` must have arm64 versions; apt packages and native gem extensions must compile).

### Step 2 — `rails_gems` 2.2.0 (`rails_gems`, `circleci_rails_gems`)
After Step 1, run `bin/script.sh init rails_gems 2.2.0` (there is no `production_rails_gems`; `init` skips it). Check that `FROM` now points to `ruby_331:1.2.0` / `circleci_ruby_331:1.2.0` and `scripts:0.11.0`, and apply the same `scripts` compatibility check as in Step 1. If the bundler pin in `home/Gemfile` is stricter than `'>= 2.5.13'`, relax it to match `ruby_331` (the same fix #204 needed for `rails_bower`). Build, test, and check arm64 as in Step 1.

## Files to Change
- `ruby_331/1.2.0/**`, `circleci_ruby_331/1.2.0/**`, `production_ruby_331/1.2.0/**` — new versions created by `init`, with `FROM`/README adjustments
- `rails_gems/2.2.0/**`, `circleci_rails_gems/2.2.0/**` — new versions created by `init`
- `version` — `ruby_331`, `circleci_ruby_331`, `production_ruby_331` → `1.2.0`; `rails_gems`, `circleci_rails_gems` → `2.2.0`

## CI Checks
- Local: `bin/script.sh build <images>` and `bin/script.sh test <images>` (these exit non-zero on failure since #205)
- Release (on tag): CircleCI `release-ruby_331`, `release-rails_gems` jobs (`bin/image.sh push`, multi-arch buildx)

## Notes
- `rails_gems` Dockerfiles have `FROM` base before `FROM scripts`. `init` still rewrites both tags, but check the result.
- Don't delete the old version folders.
