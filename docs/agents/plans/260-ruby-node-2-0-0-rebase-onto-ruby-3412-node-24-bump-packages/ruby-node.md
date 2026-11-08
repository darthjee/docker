# Plan: ruby_node 2.0.0: rebase onto ruby_3412, Node 24, bump packages

Main plan: [plan.md](plan.md)

## Overview
New `2.0.0` versions of `ruby_node`, `circleci_ruby_node` and `production_ruby_node`, rebased from `ruby_331` (Ruby 3.3.1) onto `ruby_3412` (Ruby 3.4.12), moving Node 22 → 24.

## Context
- Parents are published on Docker Hub for amd64 + arm64: `darthjee/ruby_3412:1.0.0`, `darthjee/circleci_ruby_3412:1.0.0`, `darthjee/production_ruby_3412:1.0.0`.
- `ruby_3412` / `production_ruby_3412` are Debian trixie; `circleci_ruby_3412` (cimg) is Ubuntu jammy. nodesource 24.x supports both; `curl` is present in all three.
- `1.6.0/home/Gemfile` is identical across the three images and is never copied by any Dockerfile — the gems come from the base image.
- `ruby_node` has no `scripts` build stage, so the epic's `scripts:0.15.0` rule does not apply.
- Children: `rails_bower` (deprecated, stays on `ruby_node:1.6.0`) and `rails_yarn` (#261) — neither is touched here.

## Steps

- [01 — Create the 2.0.0 versions](ruby-node/01-create-versions.md)
- [02 — Delete home/ and rewrite the Dockerfiles](ruby-node/02-update-dockerfiles.md)
- [03 — Update the subtests](ruby-node/03-update-tests.md)
- [04 — Rewrite the READMEs](ruby-node/04-write-readmes.md)
- [05 — Root wiring (architect)](ruby-node/05-root-wiring.md)
- [06 — Build and test on both arches](ruby-node/06-build-and-test.md)

## CI Checks
- `ruby_node`, `circleci_ruby_node`, `production_ruby_node`: `bin/script.sh test ruby_node` (CI release jobs: `release-ruby_node`, `release-circleci_ruby_node`, `release-production_ruby_node`, tag-only).

## Notes
- Node 24 via nodesource is a decision, not a default: do not switch to Node 26 or to copying official binaries.
- Do not reintroduce `curl -L https://npmjs.org/install.sh | /bin/bash`; use the npm bundled with `nodejs`.
- `--no-install-recommends` is intentional; if a child later needs e.g. `python3`, the child adds it.
- Do not patch or remove `1.5.0` / `1.6.0`.
