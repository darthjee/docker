# Issue: taa 2.0.0: rebase onto new rails_yarn and bump dependencies

## Description
`taa` (`1.7.0`, with `circleci_` and `production_` counterparts) is built on `rails_yarn:1.3.0` (Ruby 3.3.1). `rails_yarn 2.0.0` (#261, merged) moves to Ruby 3.4.12 / Node 24 on `ruby_node:2.0.0`. Part of epic #256.

## Problem
- `taa` still inherits the old Ruby 3.3.1 runtime and `scripts:0.11.0`.
- Its Gemfile pins `ruby '3.3.1'` and older versions of gems now shared with `rails_yarn 2.0.0` (rails 7.2.2.1, puma, rack, rake, nokogiri, rubocop family, rspec family, ...).
- `taap` (#263) depends on this image.

## Expected Behavior
- New version `2.0.0` (major, inherited Ruby runtime change) for `taa`, `circleci_taa` and `production_taa`, built on `{,circleci_,production_}rails_yarn:2.0.0` and `scripts:0.15.0`.
- Builds and `bin/script.sh test` pass on `linux/amd64` and `linux/arm64` for all three images.

## Solution
- Create the versions with `bin/script.sh init <image> 2.0.0` for all three images; never patch `1.7.0` in place.
- Dockerfiles: `FROM darthjee/scripts:0.15.0 AS scripts`, `FROM darthjee/{,circleci_,production_}rails_yarn:2.0.0 AS base`; keep the existing builder/final stages.
- Hardening, matching #261:
  - uppercase `AS`; `ENV K=V` form;
  - circleci: chain the yarn-cache seeding step (`mkdir -p ... && cp -R ...`) with `&&`;
  - production: drop `RUN bundle config set without 'development test'` only if `production_rails_yarn:2.0.0`'s inherited `BUNDLE_WITHOUT=development:test` already excludes those groups in the builder stage (verify; keep the line otherwise).
- Gemfile/Gemfile.lock (identical across the three images): `ruby '3.4.12'`, `bundler '>= 4.0.24'`; gems shared with `rails_yarn 2.0.0` take its exact versions; taa-only gems (`azeroth 2.2.0`, `darthjee-active_ext 1.4.0`, `jace 0.1.2`, `tarquinn 0.5.0`, `magicka 1.2.0`) are already at their latest releases and stay. Regenerate the lock in a Ruby 3.4.12 container with `x86_64-linux` and `aarch64-linux` platforms.
- package.json: `js-cookie` 3.0.8 (matching `rails_yarn 2.0.0`); `cyberhawk` stays at `0.8.0` for now; `johto ^0.0.1` and `angular`/`angular-route` 1.8.3 (final) unchanged.
- Update `version` and each new `README.md` (per `docs/agents/image-readme.md`). CircleCI `requires` already point at `release-*rails_yarn`, so no wiring change.
- Tests: keep existing subtests; no new subtests.

## Depends on
- #257 (scripts 0.15.0) and #261 (rails_yarn 2.0.0), both merged.
- `{,circleci_,production_}ruby_node:2.0.0` and `{,circleci_,production_}rails_yarn:2.0.0` are not yet on Docker Hub: publish them first, or build them locally (in dependency order) before building `taa`.

## Benefits
- `taa` (and `taap` downstream) run on a supported Ruby/Node stack with current, consistent dependency versions.
