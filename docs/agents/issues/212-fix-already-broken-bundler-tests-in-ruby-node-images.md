# Issue: Fix already-broken bundler tests in ruby-node images

## Description
Once #205 made `bin/script.sh test` run the real `/home/test/test.sh` and fail when any subtest fails, several ruby-node image variants started failing their `bundler.sh` subtest (`node.sh` passes everywhere). These failures already existed: the old `|| exit 0` runner hid them.

The failure list below comes from a fresh run on 2026-10-30 against the versions pinned in `version`, after #202 (taap 1.5.0) and #204 (rails_bower 1.5.0) landed.

## Problem
Failing (8 of 15):
- **ruby_node, circleci_ruby_node, production_ruby_node 1.5.0:** `Gemfile not found` (`/home/app/app/Gemfile` / `/home/circleci/project/Gemfile`). These images ship no `home/` or Gemfile, so `bundle check` can never pass.
- **circleci_taa 1.5.0:** `/home/circleci/app/Gemfile not found`. The subtest uses the wrong path; other circleci images use `/home/circleci/project/Gemfile`.
- **production_taa 1.5.0:** `bundle check` reports 31 missing gems from the development/test groups (`factory_bot`, ...). The production image leaves those groups out on purpose.
- **rails_yarn, circleci_rails_yarn, production_rails_yarn 1.1.0:** the published images no longer match the repo's `home/Gemfile`. `bundle check` reports missing runtime gems (execjs, json, i18n, zeitwerk, sprockets, ...). production_rails_yarn also reports missing development/test gems. The shared Gemfile also lists `rubocop-rspec` twice, which Bundler warns about.

Passing (7 of 15): taa; taap, circleci_taap and production_taap 1.5.0; rails_bower, circleci_rails_bower and production_rails_bower 1.5.0. The earlier taap 1.4.2 and rails_bower 1.4.0 failures went away when those lines moved to 1.5.0.

## Expected Behavior
`bin/script.sh test ruby_node taa taap rails_bower rails_yarn` exits 0 for every image version pinned in `version`. Version folders that are no longer pinned (taap 1.4.2, rails_bower 1.4.0) are out of scope.

## Solution
- **ruby_node (all 3), test only, same version:** replace `bundler.sh` with a smoke test that checks ruby, gem and bundler run (e.g. `ruby --version`, `gem --version`, `bundle --version`).
- **circleci_taa, test only, same version:** point `bundler.sh` at `/home/circleci/project/Gemfile`.
- **production_taa, test only, same version:** run `BUNDLE_WITHOUT=development:test bundle check ...`, the same way production_taap 1.5.0 does.
- **rails_yarn (all 3), image change, new version:** add a new version (e.g. 1.1.1) for rails_yarn, circleci_rails_yarn and production_rails_yarn, rebuilt from the current Gemfile. Remove the duplicate `rubocop-rspec` line, update `version`, and use `BUNDLE_WITHOUT=development:test` in production_rails_yarn's `bundler.sh`.

Test-only changes keep the same version, because the release job ignores `test/` (see #205). Image changes need a new version.

## Benefits
`bin/script.sh test` can be trusted for the ruby-node family: a failure means a real regression, not an old broken test.
