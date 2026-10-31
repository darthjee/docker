# Issue: Fix already-broken bundler tests in ruby_331 and rails_gems images

## Description
Since #205, `bin/script.sh test` runs the real `/home/test/test.sh` and fails when any subtest fails. Four Ruby images now fail their `bundler.sh` subtest. They were already broken; the old `|| exit 0` runner hid the failures.

`circleci_ruby_331 1.1.1` passes for now, but has the same drift risk.

## Problem
The test image (`Dockerfile.test`) copies `<image>/<version>/home` (only a `Gemfile`, no `Gemfile.lock`) into the working directory and runs `bundle check --gemfile=...`. With no lockfile, `bundle check` re-resolves transitive dependencies against today's rubygems.org. It then expects newer versions than the ones installed when the image was built:

- **ruby_331 1.1.1:** missing transitive gems such as `i18n (1.15.2)`, `concurrent-ruby (1.3.8)`, `minitest (6.0.6)`, `bigdecimal (4.1.3)`, `parser (3.3.13.0)`, `json (2.21.2)`, `zeitwerk (2.8.3)`.
- **production_ruby_331 1.1.1:** the same, plus every development/test gem (`pry`, `simplecov`, `rubocop`, `rspec*`, ...). The image is built with `bundle config set without 'development test'`, but the test checks every group.
- **rails_gems 2.1.1** and **circleci_rails_gems 2.1.1:** the `Gemfile` lists `rubocop-rspec (= 3.9.0)` twice in the `development` group, plus the same missing transitive gems (`rack-session`, `rack-test`, `rails-html-sanitizer`, ...).

## Expected Behavior
`bin/script.sh test` exits 0 for `ruby_331`, `circleci_ruby_331`, `production_ruby_331`, `rails_gems` and `circleci_rails_gems`. The tests keep passing when transitive dependencies publish new releases, because the build and the test use the same pinned resolution.

## Solution
- **Ship a `Gemfile.lock`:** add one next to `home/Gemfile` in new versions of `ruby_331`, `circleci_ruby_331`, `production_ruby_331`, `rails_gems` and `circleci_rails_gems`, created with `bin/script.sh init`. The Dockerfiles already copy `home/*` into the builder, and `Dockerfile.test` copies `home` into the test image, so `bundle_builder.sh` and `bundle check` both use the lockfile.
- **rails_gems / circleci_rails_gems:** remove the duplicate `rubocop-rspec` entry from `home/Gemfile` in the new version. Their `FROM` moves to the new `ruby_331` / `circleci_ruby_331` versions.
- **production_ruby_331:** its `bundler.sh` runs the check with `BUNDLE_WITHOUT=development:test`, as `production_taap/1.5.0/test/subtests/bundler.sh` already does. Apply this to the existing `1.1.1` test (test-only, same version, see #205) and to the new version.
- **Relation to #210:** this issue goes first and publishes the new versions (amd64 is fine). #210 then republishes the chain multi-arch from these Gemfiles/lockfiles.
- **Out of scope:** the other Ruby images (`ruby_node`, `rails_yarn`, `taa`, `taap`, `rails_bower`) are tracked in #221.
