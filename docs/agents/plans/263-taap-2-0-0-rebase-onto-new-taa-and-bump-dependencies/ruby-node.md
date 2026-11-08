# Ruby-Node Plan: taap 2.0.0: rebase onto new taa and bump dependencies

Main plan: [plan.md](plan.md)

## Overview
Bump `taap` and its `circleci_`/`production_` counterparts from `1.7.0` to `2.0.0`. This is a major bump because the inherited Ruby runtime changes from 3.3.1 to 3.4.12, along with Node 24.

## Context
- `taa 2.0.0` (#262) is merged. It runs Ruby 3.4.12 and Node 24, and builds on `rails_yarn:2.0.0` and `scripts:0.15.0`.
- `taap 1.7.0` builds on `taa:1.7.0` and `scripts:0.11.0`.
  - Its Gemfile is the taa 1.7.0 Gemfile plus `danica 3.0.0` and `gnuplot 2.6.2`, and it is identical across the three variants.
  - The final stage installs the apt package `gnuplot`.
- Existing subtests:
  - all three variants: `bundler.sh`, `gems.sh`, `gnuplot.sh`
  - circleci only: `user.sh`, `yarn_cache.sh`

## Steps

- [01 — Create the 2.0.0 versions](ruby-node/01-create-versions.md)
- [02 — Update the Dockerfiles](ruby-node/02-update-dockerfiles.md)
- [03 — Bump dependencies](ruby-node/03-bump-dependencies.md)
- [04 — Update the READMEs](ruby-node/04-write-readmes.md)
- [05 — Build and test](ruby-node/05-build-and-test.md)

## CI Checks
- For each of `taap`, `circleci_taap` and `production_taap`, with `PLATFORM=linux/amd64` and `PLATFORM=linux/arm64`: run `bin/image.sh build <image>`, then `bin/image.sh test <image>`. The CI jobs are `build-<image>` / `release-<image>`.

## Notes
- The `{,circleci_,production_}taa:2.0.0` images, and their own parents `ruby_node`/`rails_yarn` 2.0.0, were not on Docker Hub at planning time, and a push needs explicit user approval.
  - If they are still missing, build them locally first, in this order: `ruby_node` → `rails_yarn` → `taa`.
  - `scripts:0.15.0` and `ruby_3412:1.0.0` are published.
- `danica 3.0.0` and `gnuplot 2.6.2` are already the latest releases.
- Delta rule (to be documented in #274): `bundle_builder.sh` only copies what is new relative to the base. Gems shared with `taa` must therefore use exactly the base's versions, or they will be duplicated.
