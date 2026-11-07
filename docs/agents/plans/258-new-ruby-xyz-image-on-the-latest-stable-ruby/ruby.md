# Plan: New ruby_3412 image on Ruby 3.4.12

Issue: [258-new-ruby-xyz-image-on-the-latest-stable-ruby.md](../../issues/258-new-ruby-xyz-image-on-the-latest-stable-ruby.md)

## Overview
Add a new Ruby image family on Ruby 3.4.12 next to the frozen `ruby_331`: `ruby_3412`, `circleci_ruby_3412` and `production_ruby_3412`, all at `1.0.0`.

## Context
- `bin/script.sh init` only versions an image that is already in `version` (it runs `cp -R <image>/<current> <image>/<new>`), so it can't create a new image. The new folders are copied by hand from `<variant>ruby_331/1.2.0`.
- #257 is merged: `scripts=0.15.0` is in `version`, and that is the scripts build stage to use.
- Base images: `ruby:3.4.12` (plain tag, Debian trixie) for dev/production, `cimg/ruby:3.4.12` for circleci. Both tags were confirmed on Docker Hub.
- Today dev/production install `bundler:2.5.11` and circleci installs `bundler:2.6.8`, while the dev lock file says `BUNDLED WITH 4.0.23`. All three should use one, latest Bundler.
- `cc-test-reporter` (circleci only) downloads from a URL that now returns HTTP 404, and nothing calls it. Coverage goes to Codacy, whose reporter projects fetch at CI time with `curl … get.sh`. Drop it and install nothing in its place.
- `rails_gems` (#259) stays on Rails 7.2, so `activesupport` stays on the latest 7.2.x patch. Other gems move to their latest releases within their current major.
- `ruby_331` stays frozen at `1.2.0`: no new version, no edits.

## Steps

- [01 — Copy the ruby_331 family into ruby_3412/1.0.0](ruby/01-copy-image-folders.md)
- [02 — Update the Dockerfiles](ruby/02-update-dockerfiles.md)
- [03 — Bump the Gemfiles and regenerate the lock files](ruby/03-bump-gems.md)
- [04 — Write the image READMEs](ruby/04-write-readmes.md)
- [05 — Root-level wiring (architect)](ruby/05-root-wiring.md)
- [06 — Build and test](ruby/06-build-and-test.md)

## CI Checks
- `ruby_3412`, `circleci_ruby_3412`, `production_ruby_3412`: `bin/script.sh test ruby_3412`. This runs `bin/image.sh test` for the dev image and both counterparts, through `Dockerfile.test` and the `test` service in `docker-compose.yml`.
- `.circleci/config.yml` only has tag-triggered `release-<image>` jobs. Nothing runs on branches, so the local test plus a multi-arch `docker buildx build --platform linux/amd64,linux/arm64` is the check.

## Notes
- Moving from bookworm to Debian trixie may change native-extension builds (e.g. `psych`/`libyaml`, which `rubocop`/`reek` need). If `bundle install` fails on a missing `-dev` package, add it to the base stage. Do not switch to `-bookworm`.
- Keep each image's `test/` folder as it is: one `bundle check` subtest, with no new subtests.
- If a gem's latest release within its major doesn't support Ruby 3.4, keep the highest version that does and note it in the PR.
- Children (`rails_gems`, `ruby_node`, `rails_yarn`) are rebased in #259–#261. Do not touch them here.
