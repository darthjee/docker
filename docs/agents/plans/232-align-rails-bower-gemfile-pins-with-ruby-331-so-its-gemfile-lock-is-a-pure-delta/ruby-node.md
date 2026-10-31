# Plan: Align rails_bower Gemfile pins with ruby_331 so its Gemfile.lock is a pure delta

Issue: [232-align-rails-bower-gemfile-pins-with-ruby-331-so-its-gemfile-lock-is-a-pure-delta.md](../../issues/232-align-rails-bower-gemfile-pins-with-ruby-331-so-its-gemfile-lock-is-a-pure-delta.md)

## Overview
Create `rails_bower`, `circleci_rails_bower` and `production_rails_bower` 2.0.0 from 1.6.0. Change the Gemfile pins that downgrade gems installed by `ruby_331` 1.2.0 to the parent's versions, and bump only the pins those new versions force. Then regenerate each variant's `Gemfile.lock`, seeded from the matching `ruby_331/1.2.0` lockfile, so no parent gem changes version.

## Context
#221 shipped lockfiles in rails_bower 1.6.0. Its exact pins, such as `rails 7.0.4.3`, `rubocop 1.59.0` and `sinclair 2.1.1`, move 17 gems away from the parent's versions, so both versions end up installed. The fix is a breaking gem-version change for downstream projects, with Rails going from 7.0 to 7.2, so it ships as a major release. Base images stay the same: `*ruby_node:1.6.0` and `scripts:0.11.0`.

## Steps

- [01 — Create the 2.0.0 version folders](ruby-node/01-create-2-0-0-folders.md)
- [02 — Align the Gemfile pins with ruby_331](ruby-node/02-align-gemfile-pins.md)
- [03 — Regenerate the lockfiles as a pure delta](ruby-node/03-regenerate-lockfiles.md)
- [04 — Build, test, and update docs and versions](ruby-node/04-build-test-docs-version.md)

## CI Checks
- `rails_bower`, `circleci_rails_bower`, `production_rails_bower`: `bin/script.sh build <image>` then `bin/script.sh test <image>`, or `run_checks.sh ruby-node` (CI jobs: `release-rails_bower`, `release-circleci_rails_bower`, `release-production_rails_bower`)

## Notes
- The scope is the conflicting gems plus their fallout. Leave the other pins (puma, rack, nokogiri, newrelic_rpm, etc.) unchanged unless the new versions force a change.
- Don't add the parent's extra dev gems (simplecov-html, simplecov-lcov, rubocop-rake) to the rails_bower Gemfile.
- Gems that may need a bump for Rails 7.2: `rspec-rails` (6.0.x officially supports Rails up to 7.0; 7.x supports 7.2), `web-console`, `rails-controller-testing` and `sass-rails`/`sassc-rails`. Check sinclair 3 against `zyra` and `darthjee-core_ext`. Bump a pin only when resolution or the image tests require it.
- Keep 1.6.0 untouched; it stays published as the last Rails 7.0 image.
- Docker disk can fill during multi-variant builds, so prune the build cache if needed.
