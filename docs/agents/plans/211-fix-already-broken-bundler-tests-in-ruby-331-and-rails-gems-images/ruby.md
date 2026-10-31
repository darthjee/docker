# Ruby Plan: Fix already-broken bundler tests in ruby_331 and rails_gems images

Main plan: [plan.md](plan.md)

## Overview
New versions `ruby_331` 1.1.2 (plus circleci/production) and `rails_gems` 2.1.2 (plus circleci) ship a `Gemfile.lock` next to `home/Gemfile`, so the build and `bundle check` use the same resolution. `rails_gems` drops its duplicate `rubocop-rspec` entry. The `production_ruby_331` bundler test checks only the groups the image installs, both on the existing 1.1.1 (test-only) and on the new 1.1.2.

## Context
- `Dockerfile.test` copies `<image>/<version>/home` into the test image's working directory, and `bundler.sh` runs `bundle check --gemfile=<workdir>/Gemfile`. With no lockfile, Bundler re-resolves transitive gems against current rubygems.org and reports versions newer than the ones in the image as missing.
- Every Dockerfile in scope already copies `home/*` into the builder stage before `bundle_builder.sh` runs `bundle install`. A `Gemfile.lock` placed in `home/` is therefore picked up by both the build and the test, with no Dockerfile change.
- `production_ruby_331` is built with `bundle config set without 'development test'`. `production_taap/1.5.0/test/subtests/bundler.sh` already uses `BUNDLE_WITHOUT=development:test bundle check ...`.
- `bin/script.sh init <image>` copies the current version folder of `<image>`, `circleci_<image>` and `production_<image>` to the next patch version, bumps `version`, and moves each Dockerfile's `darthjee/*` `FROM` tags to the versions in `version`.
- #210 will republish this chain multi-arch on top of these versions, and #221 tracks lockfiles for the other Ruby images.

## Steps

- [01 — Scope the production_ruby_331 1.1.1 bundler test](ruby/01-production-bundler-test.md)
- [02 — Create ruby_331 1.1.2 with a Gemfile.lock](ruby/02-ruby-331-lockfile.md)
- [03 — Create rails_gems 2.1.2 with a deduplicated Gemfile and a Gemfile.lock](ruby/03-rails-gems-lockfile.md)
- [04 — Build and test every image in scope](ruby/04-build-and-test.md)

## CI Checks
- No PR-time test job exists for these images. `.circleci/config.yml` only has `release-*` jobs (`release-ruby_331`, `release-circleci_ruby_331`, `release-production_ruby_331`, `release-rails_gems`, `release-circleci_rails_gems`), which publish the versions listed in `version` after merge.
- Local checks: `bin/script.sh pre_build ruby_331 rails_gems`, `bin/script.sh build ruby_331 rails_gems`, `bin/script.sh test ruby_331 rails_gems`.

## Notes
- Generate each lockfile inside the image's own Ruby (`ruby:3.3.1` / `cimg/ruby:3.3.1`), not with the host Ruby, so `RUBY VERSION` and `BUNDLED WITH` match the image.
- Add both `x86_64-linux` and `aarch64-linux` platforms (`bundle lock --add-platform ...`). Native gems such as `nokogiri` and `sqlite3` then resolve on both architectures, and #210 can build arm64 without regenerating the lock.
- Pin the lockfile's transitive versions to what resolves today. Do not hand-edit them to match the old 1.1.1/2.1.1 images.
- Do not archive the 1.1.1/2.1.1 folders. Downstream images (`ruby_node`, `rails_yarn`, `taa`, ...) still build `FROM` them until #210/#221 move them.
- Commit a temporary `bin/script.sh test` failure on 1.1.1/2.1.1 only for the expected drift. After step 01, only `production_ruby_331` 1.1.1 changes among the old versions.
