# Issue: rails_gems 3.0.0: rebase onto ruby_3412 and bump gems

## Description

Third sub-issue of epic #256. `rails_gems` (`2.2.0`) and its counterpart `circleci_rails_gems` (`2.2.0`; there is no `production_rails_gems`) are still built on `ruby_331:1.2.0` (Ruby 3.3.1), `scripts:0.11.0`, and Rails `7.2.2.1`. This issue moves both onto the new `ruby_3412` images introduced by #258 and bumps their gems.

**Depends on:** #257 (`scripts:0.15.0`) and #258 (`ruby_3412`) — both merged. `darthjee/scripts:0.15.0`, `darthjee/ruby_3412:1.0.0` and `darthjee/circleci_ruby_3412:1.0.0` (amd64 + arm64) are already published on Docker Hub, so this issue can build against them directly.

No image in the repo builds `FROM` `rails_gems`/`circleci_rails_gems`, so no child image needs a follow-up release.

## Problem

- Both images run Ruby 3.3.1 and copy from `scripts:0.11.0`.
- Their gems are behind (Rails `7.2.2.1`, rubocop `1.85.1`, nokogiri `1.19.1`, …).
- `sqlite3` is pinned at `1.4.2`, which compiles from source and forces `circleci_rails_gems` to `apt-get install libsqlite3-dev`; the latest 1.x (`1.7.3`) ships no precompiled gem for Ruby 3.4.
- Their Dockerfiles use the old `as` / `ENV K V` syntax.

## Expected Behavior

- New `rails_gems/3.0.0` and `circleci_rails_gems/3.0.0`, based on `darthjee/ruby_3412:1.0.0` / `darthjee/circleci_ruby_3412:1.0.0`, with the `scripts` stage on `darthjee/scripts:0.15.0`.
- Ruby 3.4.12 and Bundler 4.0.24 inherited from the parents; Gemfile `ruby '3.4.12'`.
- Rails stays on 7.2.x (`7.2.4`); no Rails 8.
- `sqlite3 2.10.2` (precompiled for both arches); `circleci_rails_gems` no longer installs `libsqlite3-dev`.
- Both images build and pass `bundle check` on `linux/amd64` and `linux/arm64`.
- On release, `latest` of both images moves to `3.0.0`.
- Older versions (`2.1.1`, `2.1.2`, `2.2.0`) stay frozen.

## Solution

### 1. Create the versions

`bin/script.sh init rails_gems 3.0.0` and `bin/script.sh init circleci_rails_gems 3.0.0` — 3.0.0 (not the epic's usual `x.(y+1).0`) because the Ruby runtime changes (3.3.1 → 3.4.12), so anyone pinned to `2.x` does not get the new Ruby by surprise. Never patch `2.2.0` in place.

### 2. Dockerfiles

Follow the `ruby_3412` style from #258: `AS`, `ENV K=V`, `scripts` stage first. Stage layout and copy targets otherwise unchanged.

`rails_gems/3.0.0/Dockerfile`:

```dockerfile
FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/ruby_3412:1.0.0 AS base
######################################

FROM base AS builder

COPY --chown=app:app home/* /home/app/app/

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR=/home/app
RUN bundle_builder.sh

#######################
#FINAL IMAGE

FROM base

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
COPY --chown=app:app home/* /home/app/app/
```

`circleci_rails_gems/3.0.0/Dockerfile` — drops the `USER root` / `apt-get install -y libsqlite3-dev` / `USER circleci` block, and runs `bundle_builder.sh` directly like its parent instead of via `/bin/bash`:

```dockerfile
FROM darthjee/scripts:0.15.0 AS scripts
FROM darthjee/circleci_ruby_3412:1.0.0 AS base
######################################

FROM base AS builder

COPY --chown=circleci:circleci home/* /home/circleci/project/

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh

ENV HOME_DIR=/home/circleci
ENV BUNDLE_FOLDER=/home/circleci/.rubygems
RUN bundle_builder.sh

######################################
#FINAL IMAGE

FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/bundle/ /home/circleci/.rubygems/
```

### 3. Gemfile and lock files

Both images share one identical Gemfile (keep them identical; `bin/script.sh update_deps` can mirror the pins). `ruby '3.4.12'`. Policy: latest release within each gem's current major; Rails on 7.2.x.

| Gem | 2.2.0 | 3.0.0 |
|---|---|---|
| `rails`, `activesupport`, `actionpack`, `activerecord`, `actionview` | 7.2.2.1 | 7.2.4 |
| `rake` | 13.2.1 | 13.4.2 |
| `rack` | 3.1.20 | 3.2.8 (actionpack 7.2.4 allows `< 3.3`) |
| `nokogiri` | 1.19.1 | 1.19.7 |
| `sqlite3` | 1.4.2 | **2.10.2** (see below) |
| `factory_bot` | 6.5.6 | 6.6.0 |
| `yard` | 0.9.38 | 0.9.45 |
| `rubocop` | 1.85.1 | 1.92.2 |
| `rubocop-rspec` | 3.9.0 | 3.10.2 |
| `rubocop-rails` | 2.34.3 | 2.38.0 |
| `rubocop-rspec_rails` | 2.32.0 | 2.33.0 |
| `rspec-core` | 3.13.6 | 3.13.7 |
| `rspec-expectations` | 3.13.5 | 3.13.6 |
| `rspec-mocks` | 3.13.8 | 3.13.9 |
| `rspec-support` | 3.13.7 | 3.13.8 |
| `rspec-rails` | 8.0.3 | 8.1.0 |

Held on purpose (same as `ruby_3412` in #258):

- `pry` stays `0.14.2` — `pry-nav 1.0.0` requires `pry < 0.15`.
- `reek` stays `6.5.0` — `rubycritic 5.0.0` requires `reek ~> 6.5.0`.
- `simplecov` stays `0.22.0` — `1.x` is a new major.

Unchanged because already latest: `sinclair 3.1.0`, `pry-nav 1.0.0`, `simplecov-html 0.13.2`, `simplecov-lcov 0.9.0`, `rubycritic 5.0.0`, `yardstick 0.9.9`, `rubocop-factory_bot 2.28.0`, `rubocop-rake 0.7.1`, `rspec 3.13.2`, `rails-controller-testing 1.0.5`.

**`sqlite3` 2.10.2** is the one deliberate exception to the same-major rule: `1.7.3` only ships precompiled Linux gems for Ruby `< 3.4`, so on 3.4.12 it would compile from source again; `2.10.2` ships precompiled `x86_64-linux-gnu` / `aarch64-linux-gnu` gems (Ruby `>= 3.2, < 4.1`) with SQLite vendored, and Rails 7.2.4 accepts it (`gem "sqlite3", ">= 1.4"`).

Regenerate both lock files keeping the four `PLATFORMS` entries: `x86_64-linux`, `x86_64-linux-gnu`, `aarch64-linux`, `aarch64-linux-gnu`.

### 4. Root wiring

- `version`: `rails_gems=3.0.0`, `circleci_rails_gems=3.0.0`.
- `.circleci/config.yml`: `release-rails_gems` requires `[release-scripts, release-ruby_3412]` (was `release-ruby_331`); `release-circleci_rails_gems` requires `[release-scripts, release-circleci_ruby_3412]` (was `release-circleci_ruby_331`).
- Any docs listing the `rails_gems` parent (e.g. `docs/agents/architecture.md`, `.claude/agents/ruby.md`) now name `ruby_3412`.

### 5. READMEs

Rewrite `rails_gems/3.0.0/README.md` and `circleci_rails_gems/3.0.0/README.md` per `docs/agents/image-readme.md` (Ruby 3.4.12, Rails 7.2.4, new parent).

### 6. Multi-arch and tests

Native gems: `nokogiri` and `sqlite3` install precompiled on both arches; `bigdecimal`, `date`, `json`, `io-console`, `erb`, `nio4r`, `prism`, `racc`, `websocket-driver` compile from source in the builder stage (both parents ship a full toolchain). No new apt packages; a native-extension compile failure on either arch is a blocker.

No new subtests — the existing `test/subtests` (`bundle check`) carry over unchanged. Verify with:

- `bin/script.sh test rails_gems` (amd64);
- `PLATFORM=linux/arm64 bin/script.sh test rails_gems`;
- `docker buildx build --platform linux/amd64,linux/arm64` of both images, without `--push`.

### Out of scope

- Rails 8.
- Patching or removing `rails_gems` `2.1.1` / `2.1.2` / `2.2.0`.
- A `production_rails_gems` image.
- `ruby_331` and every other image (the Ruby+Node family has its own sub-issues).

## Benefits

- `rails_gems` users get Ruby 3.4.12 and current Rails 7.2 / tooling patches without a Rails 8 migration.
- `sqlite3` 2.x removes the source build and the `libsqlite3-dev` apt layer, making both arches faster and more reliable to build.
- Dockerfiles match the modern style used across the `ruby_3412` family.
