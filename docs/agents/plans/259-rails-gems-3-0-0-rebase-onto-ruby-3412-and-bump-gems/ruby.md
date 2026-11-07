# Plan: rails_gems 3.0.0: rebase onto ruby_3412 and bump gems

Main plan: [plan.md](plan.md)

## Overview
New `3.0.0` versions of `rails_gems` and `circleci_rails_gems` (no production counterpart exists), rebased from `ruby_331`/Ruby 3.3.1 onto `ruby_3412`/Ruby 3.4.12, with gems bumped within their current majors (Rails stays on 7.2.x) and `sqlite3` moved to the precompiled 2.x line.

## Context
- Parents are already published on Docker Hub for amd64 + arm64: `darthjee/scripts:0.15.0`, `darthjee/ruby_3412:1.0.0`, `darthjee/circleci_ruby_3412:1.0.0` (Ruby 3.4.12, Bundler 4.0.24).
- `rails_gems/2.2.0/home/Gemfile` and `circleci_rails_gems/2.2.0/home/Gemfile` are identical; keep the 3.0.0 pair identical too.
- No image in the repo builds `FROM` `rails_gems`/`circleci_rails_gems`, so there are no children to re-release.
- The version is 3.0.0 (not 2.3.0) because the Ruby runtime changes.

## Steps

- [01 — Create the 3.0.0 versions](ruby/01-create-versions.md)
- [02 — Update the Dockerfiles](ruby/02-update-dockerfiles.md)
- [03 — Bump the Gemfile and regenerate the locks](ruby/03-bump-gems.md)
- [04 — Rewrite the READMEs](ruby/04-write-readmes.md)
- [05 — Root wiring (architect)](ruby/05-root-wiring.md)
- [06 — Build and test on both arches](ruby/06-build-and-test.md)

## CI Checks
- `rails_gems`, `circleci_rails_gems`: `bin/script.sh test rails_gems` (CI release jobs: `release-rails_gems`, `release-circleci_rails_gems`, tag-only).

## Notes
- `sqlite3 2.10.2` is the one deliberate major bump: `1.7.3` has no precompiled gem for Ruby 3.4. Rails 7.2.4 accepts it (`>= 1.4`).
- Held on purpose: `pry 0.14.2` (`pry-nav 1.0.0` needs `< 0.15`), `reek 6.5.0` (`rubycritic 5.0.0` needs `~> 6.5.0`), `simplecov 0.22.0` (1.x is a new major).
- Native gems other than `nokogiri`/`sqlite3` compile from source in the builder stage; a compile failure on either arch is a blocker — do not add apt packages to work around it without flagging it.
- Do not patch or remove `2.1.1`, `2.1.2`, `2.2.0`.
- No new subtests; the existing `bundle check` subtest carries over.
