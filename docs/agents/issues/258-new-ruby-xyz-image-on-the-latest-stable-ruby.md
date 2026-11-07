# Issue: New ruby_3412 image on Ruby 3.4.12

## Description
Second sub-issue of epic #256. Ruby images are built on `ruby:3.3.1` / `cimg/ruby:3.3.1` (`ruby_331`, `circleci_ruby_331`, `production_ruby_331`, all at `1.2.0`). A runtime bump creates a new image instead of bumping the existing one.

**Depends on issues:** #257 (`scripts 0.15.0` must be merged and released first)

## Problem
Ruby 3.3.1 is outdated and the Ruby image family has no newer runtime. The gems pinned in `ruby_331` are also behind.

## Expected Behavior
- A new image `ruby_3412` exists on Ruby **3.4.12** (latest stable Ruby 3; the 4.x jump is left to a later epic), with `circleci_ruby_3412` and `production_ruby_3412` counterparts, all starting at `1.0.0`.
- They are based on `ruby:3.4.12` (dev/production; the default tag, i.e. Debian trixie) and `cimg/ruby:3.4.12` (circleci), and copy from `darthjee/scripts:0.15.0`.
- All three install the same, latest Bundler (today dev/production use 2.5.11 and circleci 2.6.8).
- Gems are bumped to their latest compatible releases, and the lock files are refreshed. `activesupport` stays on the **7.2.x** line (latest 7.2 patch): Rails 8 is out of scope, and `rails_gems` (#259) stays on Rails 7.2.
- `circleci_ruby_3412` does **not** install `cc-test-reporter`. The Code Climate download URL now returns 404, it was amd64-only, and nothing in the repo calls it. Coverage goes to Codacy, whose reporter each project downloads at CI time (`bash <(curl -Ls https://coverage.codacy.com/get.sh) report ...`). That only needs `bash` and `curl`, which `cimg/ruby` already has, so no replacement is baked into the image.
- `ruby_331` is **frozen** at `1.2.0`: no new version.
- `bin/script.sh test` passes for the three new images on `linux/amd64` and `linux/arm64`.

## Solution
1. `bin/script.sh init` only versions an existing image, so create the new folders by copying `ruby_331/1.2.0`, `circleci_ruby_331/1.2.0` and `production_ruby_331/1.2.0` to `<variant>_ruby_3412/1.0.0`.
2. Update each Dockerfile: the base image tag, `darthjee/scripts:0.15.0`, and the Bundler version. Drop the `cc-test-reporter` download from the circleci Dockerfile. Modernise the syntax while copying (`AS` instead of `as`, `ENV KEY=value`, `chown app:app`) to clear BuildKit warnings, with no behaviour change.
3. Update each `home/Gemfile` (`ruby '3.4.12'`, gem bumps) and regenerate `Gemfile.lock`.
4. Add the three images to the `version` file.
5. Add `release-ruby_3412`, `release-circleci_ruby_3412` and `release-production_ruby_3412` jobs to `.circleci/config.yml` (requiring `release-scripts`).
6. Write each image's `README.md` per `docs/agents/image-readme.md`, and add the images to the root README, AGENTS.md and `docs/agents/folder-structure.md` / `architecture.md`.
7. Run `bin/script.sh test` for each new image (the existing `bundle check` subtest; no new subtests), plus a multi-arch build.

### Common rules (from epic #256)
- Dependency updates are in scope.
- Counterparts are done in this same issue.
- Each new version's README follows `docs/agents/image-readme.md`.

## Benefits
- Ruby projects get a current runtime and up-to-date tooling.
- `ruby_331` stays available, unchanged, for projects that are not ready to move.
- Unblocks the rebase of `rails_gems`, `ruby_node` and `rails_yarn` (#259–#261).
