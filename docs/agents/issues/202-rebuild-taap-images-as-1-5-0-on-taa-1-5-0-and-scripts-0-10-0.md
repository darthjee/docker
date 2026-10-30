# Issue: Rebuild taap images as 1.5.0 on taa 1.5.0 and scripts 0.10.0

## Description

Publish a new 1.5.0 version of `taap`, `circleci_taap` and `production_taap`, built on `taa:1.5.0` (and its circleci/production versions) and `scripts:0.10.0`. This fixes the 1.4.2 images, which can no longer be built and never shipped the `danica` and `gnuplot` gems (#197, #199, #200).

Responsible agent: `ruby-node`

## Problem

`taap`, `circleci_taap` and `production_taap` (1.4.2) can no longer be built: they pin `darthjee/scripts:0.4.3`, which has been removed from Docker Hub (the Hub API returns 404). They are also still built on `taa:1.4.2` (and its circleci/production versions), while `taa` is at 1.5.0.

Separately, the published 1.4.2 images don't contain the `danica` and `gnuplot` gems their Gemfiles add (#197, #199, #200). The cause is the same outdated final stage: it copies from paths the builder stage doesn't write to (e.g. `/usr/local/bundle` and `/home/app/.cache` instead of the builder's `/home/app/bundle/`).

## Expected Behavior

- `bin/script.sh build taap` builds all three images (amd64; arm64 waits on #210).
- `danica` and `gnuplot` show up in `gem list` in each image, along with the gems inherited from `taa`. Production leaves out the development and test groups.
- All three 1.5.0 READMEs describe what the images actually ship.
- For each image, the `test/` suite passes when run directly, and fails when a Gemfile gem is missing.
- The PR closes #197, #199 and #200.

## Solution

### Scope

In scope:

- A new version (`bin/script.sh init`) of `taap`, `circleci_taap` and `production_taap`, built on `taa:1.5.0` (and its circleci/production versions) and a current `scripts` release.
- Rewriting their builder and final stages to match how `taa` 1.5.0 does it (see Image layout below).
- Shipping the `danica` and `gnuplot` gems. This closes #197, #199 and #200.

Out of scope (split into their own issues):

- `rails_bower` and its circleci/production versions, which are broken for the same reason (missing `ruby_node:1.4.0` and `scripts:0.3.2`): #204.
- Making `bin/script.sh build` and `test` exit non-zero on failure: #205.
- Republishing the Ruby image chain as multi-arch: #210.

Nothing else in the repo is built on `taap`, so no other image needs changing.

### Versioning

- Each of the three images gets a new **1.5.0** version (`bin/script.sh init <image> 1.5.0`), matching `taa` 1.5.0. This is not an in-place fix of 1.4.2.
- Bases:
  - `taap/1.5.0`: `darthjee/taa:1.5.0` and `darthjee/scripts:0.10.0`
  - `circleci_taap/1.5.0`: `darthjee/circleci_taa:1.5.0` and `darthjee/scripts:0.10.0`
  - `production_taap/1.5.0`: `darthjee/production_taa:1.5.0` and `darthjee/scripts:0.10.0`
- `scripts:0.10.0` is the latest release. `taa` 1.5.0 uses 0.8.0, but the builder layout (`/home/<user>/bundle/`, `/home/<user>/yarn/new/`) is the same.

### Image layout

#### `home/` contents

- `Gemfile`: `taa` 1.5.0's Gemfile (Ruby 3.3.1) plus `gem 'danica', '3.0.0'` and `gem 'gnuplot', '2.6.2'`. The old 1.4.2 Gemfile (`ruby '2.5.0'`, older pins, `bower-rails`, `newrelic_rpm`) is dropped.
  - `danica` has to go to 3.0.0. Version 2.7.7 needs `activesupport ~> 5.2` and `darthjee-core_ext ~> 2.x`, which conflicts with `taa` 1.5.0 (Rails 7.2, `core_ext` 3.1.0). Version 3.0.0 needs `activesupport ~> 7.2`, `core_ext ~> 3.x` and Ruby >= 3.3.1.
  - `gnuplot` 2.6.2 has no runtime dependencies.
- `bower.json` is dropped: nothing runs Bower, and `rails_yarn` doesn't install it.
- `package.json` and the yarn step are dropped: the file is identical to `taa` 1.5.0's, so `yarn_builder.sh` would add nothing. Add them back only if `taap` ever needs its own JS packages.

#### Builder stage

Only `bundle_builder.sh` from `scripts:0.10.0`, set up the same way as the matching `taa` image:

- `taap`: `HOME_DIR=/home/app`, user `app`.
- `circleci_taap`: `HOME_DIR=/home/circleci`, `BUNDLE_FOLDER=/home/circleci/.rubygems`, user `circleci` throughout (no stray `USER app`).
- `production_taap`: `RUN bundle config set without 'development test'` before running the builder, as `production_taa` does. This replaces the `--without` argument.

#### Final stage

```dockerfile
FROM base
USER root
RUN apt-get update && apt-get install -y gnuplot && rm -rf /var/lib/apt/lists/*
USER app
COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
```

`circleci_taap` uses `USER circleci` and copies `/home/circleci/bundle/` into `/home/circleci/.rubygems/`. Using the same bundle copy path as `taa` is what makes `danica` and `gnuplot` actually land in the image.

### Testing

The current tests catch nothing: `test.sh` exits 0 when a subtest fails, `test.js` is `return 0`, and `circleci_taap/1.4.2`'s `bundler.sh` checks the wrong path (`/home/app/app/Gemfile`). On top of that, `bin/image.sh test` runs `docker-compose run test pwd`, which never executes the tests at all. Fixing that runner is part of #205.

Tests for each of the three 1.5.0 images:

- `test/test.sh`: runs every `subtests/*.sh` and exits 1 if any fails.
- `subtests/bundler.sh`: `bundle check` against that variant's Gemfile (`/home/app/app/Gemfile` for `taap` and `production_taap`, the circleci project path for `circleci_taap`). The Gemfile lists `danica` and `gnuplot`, so this catches the #197/#199/#200 bug.
- `subtests/gems.sh`: `ruby -e 'require "danica"; require "gnuplot"'`.
- `subtests/gnuplot.sh`: `gnuplot --version`.
- `subtests/node.sh` and `test.js` are dropped: `taap` has no JS of its own.

Verification in the PR: until #205 lands, `bin/script.sh test taap` doesn't execute the tests. So for each image, run the real test command without the `pwd` override (e.g. `DOCKER_ID_USER=darthjee IMAGE=taap VERSION=1.5.0 USER_NAME=app IMAGE_NAME=taap_test docker-compose build test && ... docker-compose run test`), and paste the output. Also show that the tests fail when `danica` is taken out of the Gemfile.

### Counterpart images

`bin/script.sh init taap 1.5.0` creates all three variants from 1.4.2, updates `version`, and rewrites each `FROM darthjee/<img>:<tag>` to the version in `version`. That already gives `taa:1.5.0` (and its circleci/production versions) and `scripts:0.10.0`. What's left is rewriting the stages and the `home/` and `test/` contents.

| | `taap` | `circleci_taap` | `production_taap` |
|---|---|---|---|
| Base | `taa:1.5.0` | `circleci_taa:1.5.0` | `production_taa:1.5.0` |
| User | `app` | `circleci` | `app` |
| `HOME_DIR` | `/home/app` | `/home/circleci` | `/home/app` |
| Builder copies `home/` to | `/home/app/app/` | `/home/circleci/project/` | `/home/app/app/` |
| Bundle copied to | `/usr/local/bundle/` | `/home/circleci/.rubygems/` | `/usr/local/bundle/` |
| Gem groups | all | all | `without 'development test'` |
| Test Gemfile path (`WORKDIR`) | `/home/app/app/Gemfile` | `/home/circleci/project/Gemfile` | `/home/app/app/Gemfile` |

- READMEs: `init` copies each 1.4.2 README. Update all three for 1.5.0: base `taa` 1.5.0, Ruby 3.3.1, Node 22, `danica` and `gnuplot` listed, no Bower or `bower-rails`. Follow `docs/agents/image-readme.md`.
- Downstream images: none. Nothing in the repo is built on any `taap` variant.
- CircleCI: the `release-taap`, `release-circleci_taap` and `release-production_taap` jobs are keyed by image name, so there's nothing to change.
- The 1.4.2 folders stay in place. Archiving them (`bin/script.sh archive`) will be a separate change later.
- Note: `circleci_taa/1.5.0`'s test checks `/home/circleci/app/Gemfile`, which looks wrong. It's out of scope here, and #205's test-runner fix will probably surface it.

### Multi-arch compatibility

- The `taap` Dockerfiles are arch-neutral: `danica` and `gnuplot` are pure Ruby, and Debian packages `gnuplot` for arm64.
- `bin/image.sh push` releases for `linux/amd64,linux/arm64` with buildx. But `taa:1.5.0` and its circleci/production versions, like the rest of the Ruby chain, are amd64-only on Docker Hub, so the arm64 build of `taap` 1.5.0 can't succeed yet.
- Republishing the chain as multi-arch is tracked in #210. #202 is **not** blocked by it: releases only run on tags, so merging #202 releases nothing. #202 only needs the images to build and pass tests on amd64. Once #210 lands, `taap` moves to the new `taa` versions and gets its multi-arch release.

### Backward compatibility

The 1.4.2 `taap` Gemfile was never applied (the #197 bug). So the 1.4.2 images effectively ship `taa` 1.4.2's gems on Ruby 3.3.1, plus the apt `gnuplot` binary. Dropping the old Gemfile's `ruby '2.5.0'`, `bower-rails` and older pins changes nothing for consumers. What really changes is `taa` 1.4.2 → 1.5.0, plus `danica` and `gnuplot`:

| Area | 1.4.2 | 1.5.0 | Notes |
|---|---|---|---|
| `newrelic_rpm` | 8.12.0 | removed | Follows `taa`, which dropped it. Not re-added to `production_taap`: apps that need it add it themselves |
| `rack` | 2.2.6.3 | 3.1.20 | Major bump |
| `puma` | 6.0.0 | 7.2.0 | Major bump |
| `darthjee-core_ext` | 2.0.0 | 3.1.0 | Major bump; forces `danica` 3.0.0 |
| `shoulda-matchers` (test) | 5.3.0 | 7.0.1 | Major bump |
| `azeroth`, `tarquinn`, `sinclair`, `magicka`, `jace` | | | Minor bumps |
| `danica` / `gnuplot` | missing | 3.0.0 / 2.6.2 | Added (#197, #199, #200) |
| Base chain | `rails_yarn` 1.0.1 / `ruby_node` 1.4.2 | `rails_yarn` 1.1.0 / `ruby_331` 1.1.1, NodeSource 22 | Node major version may change |
| Ruby | 3.3.1 | 3.3.1 | Unchanged |

- The 1.5.0 bump signals a breaking change. The 1.4.2 tags stay on Docker Hub, and only `:latest` moves once 1.5.0 is released (after #210).
- These changes are listed in the PR description, not in the READMEs: `docs/agents/image-readme.md` keeps version-specific content out of READMEs, because `init` copies them unchanged.

## Benefits

- `taap` can be built again, on the current `taa` and `scripts`.
- The images actually ship the gems their Gemfiles list, with tests that catch it when they don't.
- Closes #197, #199 and #200 in one rewrite instead of three.
