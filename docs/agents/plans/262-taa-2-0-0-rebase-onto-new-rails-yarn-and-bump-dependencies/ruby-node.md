# Ruby-Node Plan: taa 2.0.0: rebase onto new rails_yarn and bump dependencies

Main plan: [plan.md](plan.md)

## Overview
Bump `taa` and its `circleci_`/`production_` counterparts from `1.7.0` to `2.0.0` (major: inherited Ruby runtime change 3.3.1 → 3.4.12, Node 24).

## Context
- `rails_yarn 2.0.0` (#261) is merged: Ruby 3.4.12, Node 24, Yarn 1.22.22, on `ruby_node:2.0.0`.
- `taa 1.7.0` builds on `rails_yarn:1.3.0` and `scripts:0.11.0`; its Gemfile/Gemfile.lock/package.json are identical across the three variants.
- `.circleci/config.yml` already has `release-{,circleci_,production_}taa` require `release-scripts` and `release-{,circleci_,production_}rails_yarn` — no wiring change.
- `taap` (#263) builds on `taa` and is out of scope.

## Steps

- [01 — Create the 2.0.0 versions](ruby-node/01-create-versions.md)
- [02 — Update the Dockerfiles](ruby-node/02-update-dockerfiles.md)
- [03 — Bump dependencies](ruby-node/03-bump-dependencies.md)
- [04 — Update the READMEs](ruby-node/04-write-readmes.md)
- [05 — Build and test](ruby-node/05-build-and-test.md)

## CI Checks
- `taa`, `circleci_taa`, `production_taa`: `bin/image.sh build <image>` then `bin/image.sh test <image>`, with `PLATFORM=linux/amd64` and `PLATFORM=linux/arm64` (CI jobs: `build-<image>` / `release-<image>`).

## Notes
- The six parent images `{,circleci_,production_}ruby_node:2.0.0` and `{,circleci_,production_}rails_yarn:2.0.0` were not on Docker Hub at planning time (a push needs explicit user approval). If they are still missing, build them locally first, in order (`ruby_node` → `rails_yarn`), tagging them `darthjee/<image>:2.0.0` so the taa `FROM` lines resolve.
- `cyberhawk` deliberately stays at `0.8.0` (latest is `0.11.2`, 0.x minor bumps may break); `azeroth`, `darthjee-active_ext`, `jace`, `tarquinn`, `magicka` are already at their latest releases.
- Delta rule: `bundle_builder.sh` / `yarn_builder.sh` only copy what is new relative to the base, so gems shared with `rails_yarn` must use exactly the base's versions or they will be duplicated in the image.
