# Plan: rails_yarn 2.0.0: rebase onto ruby_node 2.0.0, Node 24, bump gems and npm

Main plan: [plan.md](plan.md)

## Overview
New `2.0.0` versions of `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn`, moving from `ruby_331:1.2.0` (Ruby 3.3.1, Node 22 installed here) to `ruby_node:2.0.0` (Ruby 3.4.12, Node 24 + `ncat` inherited).

## Context
- Parents: `darthjee/ruby_node:2.0.0`, `darthjee/circleci_ruby_node:2.0.0`, `darthjee/production_ruby_node:2.0.0` (merged in #260). They must be on Docker Hub (amd64 + arm64) before CI/multi-arch builds; for local single-arch work, `bin/script.sh build <ruby_node image>` tags them locally.
- `ruby_node` / `production_ruby_node` are Debian trixie; `circleci_ruby_node` is Ubuntu jammy (cimg). Users: `app` (dev/prod), `circleci` (CI).
- `home/` holds `Gemfile`, `Gemfile.lock`, `package.json`; all three are copied into the builder and used by `bundle_builder.sh` / `yarn_builder.sh` (scripts `0.15.0`), so they stay.
- The 1.3.0 `Gemfile`s are identical across the three images; `production_` and dev locks are identical, the circleci lock differs only in the `RUBY VERSION`/`BUNDLED WITH` footer and missing `CHECKSUMS`.
- Downstream `taa`/`taap` stay on `rails_yarn:1.3.0` (separate sub-issues).

## Steps

- [01 — Create the 2.0.0 versions](ruby-node/01-create-versions.md)
- [02 — Rewrite the Dockerfiles](ruby-node/02-update-dockerfiles.md)
- [03 — Bump gems and npm packages](ruby-node/03-bump-dependencies.md)
- [04 — Rewrite the READMEs](ruby-node/04-write-readmes.md)
- [05 — Root wiring (architect)](ruby-node/05-root-wiring.md)
- [06 — Build and test on both arches](ruby-node/06-build-and-test.md)

## CI Checks
- `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn`: `bin/script.sh test rails_yarn` (CI release jobs: `release-rails_yarn`, `release-circleci_rails_yarn`, `release-production_rails_yarn`, tag-only).

## Notes
- Do not reinstall Node or `ncat` (they come from `ruby_node`); do not reintroduce `curl -L https://npmjs.org/install.sh | /bin/bash`.
- Stay on Yarn classic `1.22.22`; do not switch to corepack / Yarn Berry (breaks `yarn_builder.sh` and the `v6` cache paths).
- Stay on Rails `7.2.4` and current front-end majors (bootstrap 4, jquery 3); no new subtests.
- Do not patch or remove `1.x` versions.
