# Issue: rails_yarn 2.0.0: rebase onto ruby_node 2.0.0, Node 24, bump gems and npm

## Description
`rails_yarn` (`1.3.0`), with its `circleci_rails_yarn` and `production_rails_yarn` counterparts, is built directly on `ruby_331:1.2.0` and installs Node 22, npm (via `npm install.sh`), Yarn classic, `ncat` and `telnet` itself. It also pre-caches a set of front-end packages (Yarn cache) and pre-installs a Rails gem set (Bundler).

This issue releases `2.0.0` of all three images, **rebased onto `ruby_node:2.0.0`** (and its `circleci_`/`production_` counterparts: Ruby 3.4.12 on `ruby_3412`, Node 24, `ncat`), so Node is no longer installed here — only Yarn, `telnet` and the gem/package caches are added on top. Gems and npm packages are bumped within their current major lines.

Part of epic #256. Depends on #257 (scripts 0.15.0), #258 (ruby_3412) and #260 (ruby_node 2.0.0), all merged. `ruby_node:2.0.0` (all three variants, amd64+arm64, plus `latest`) must be published to Docker Hub before this issue is implemented (it is merged but not yet released; Docker Hub still tops out at `1.6.0`).

## Problem
- The images run Ruby 3.3.1 on `ruby_331`, which is frozen at `1.2.0` and replaced by `ruby_3412`.
- They duplicate the Node install that `ruby_node` already provides; the epic moves `ruby_node`/`rails_yarn` from Node 22 to Node 24.
- The Gemfile pins `ruby '3.3.1'` and outdated gems; the `scripts` stage is still `0.11.0`.
- The install step chains `curl -sL ... ;` with `;`, so a failed download does not fail the build; it also pipes `npm install.sh` from the network.

## Expected Behavior
- `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn` at `2.0.0` (new folders via `bin/script.sh init <image> 2.0.0`), `version` file updated, `latest` moves.
- Ruby 3.4.x and Node v24.x (inherited from `ruby_node`), Yarn `1.22.22`, `ncat` (inherited) and `telnet` available; Yarn cache and bundle pre-populated as today.
- All three build on `linux/amd64` and `linux/arm64` and pass `bin/script.sh test` with the existing subtests.

## Solution
### Dockerfiles (all three)
- `FROM darthjee/scripts:0.15.0 AS scripts`; base `darthjee/ruby_node:2.0.0` / `circleci_ruby_node:2.0.0` / `production_ruby_node:2.0.0` `AS base`.
- Drop the nodesource and `npm install.sh` steps (Node 24 and its bundled npm come from `ruby_node`). As root: `apt-get update && apt-get install -y --no-install-recommends telnet && rm -rf /var/lib/apt/lists/* && npm install -g yarn@1.22.22`, all chained with `&&` so any failure fails the build (circleci keeps creating/chowning `/home/circleci/.cache/yarn`).
- Hardening: uppercase `AS`, `ENV K=V` form, `chown app:app` (not `app.app`) in production.
- Keep the builder/final structure (`yarn_builder.sh`, `bundle_builder.sh`, Yarn cache `v6` paths, production `BUNDLE_WITHOUT=development:test`).

### Yarn
- Stay on Yarn classic `1.22.22` (latest, frozen line); Yarn Berry would break `yarn_builder.sh`, the `v6` cache layout and `taa`.

### Gems (`home/Gemfile` + `Gemfile.lock`, all three)
- `ruby '3.4.12'`, `bundler '>= 4.0.24'`.
- Stay on Rails `7.2.4` (aligned with `rails_gems 3.0.0`); gems shared with `rails_gems 3.0.0` / `ruby_3412` use the same versions as there (e.g. `rake`, `rack`, `nokogiri`, `yard`, rubocop family, rspec family); the rest bumped to the latest compatible release.
- Keep `sass-rails`, `uglifier`, `turbolinks` (already at their latest) and `observer` (required on Ruby 3.4).
- Regenerate `Gemfile.lock` (it is copied into the builder and used by `bundle install`, so it stays).

### Front-end packages (`home/package.json`)
- Stay within current majors: `js-cookie` `3.0.7` → `3.0.8`; `underscore 1.13.8`, `bootstrap 4.6.2`, `jquery 3.7.1`, `yarn 1.22.22` already at the latest of their line.

### Tests
- No new subtests; existing ones (`node.sh`, `bundler.sh`, circleci `user.sh`/`yarn_cache.sh`) must pass.

### READMEs
- Rewrite the three `2.0.0/README.md` per `docs/agents/image-readme.md`: built on `ruby_node` (Ruby 3.4.12, Node 24), Yarn 1.22.22.

### Root wiring (architect)
- `.circleci/config.yml`: `release-rails_yarn` requires `[release-scripts, release-ruby_node]`; same for `circleci_` and `production_` with their `*ruby_node` jobs.
- `.claude/agents/ruby-node.md`: `rails_yarn/` line becomes `ruby_node + Yarn` (and the `taap ← taa ← rails_yarn ← ruby_331` chain example updated).
- `docs/agents/architecture.md` tree, if it shows `rails_yarn`'s parent.

### Out of scope
- `taa`/`taap` (next sub-issues) stay on `rails_yarn:1.3.0` until rebased.

## Security and edge cases
- No more piping `npm install.sh` from the network; the nodesource setup script now lives only in `ruby_node`.
- `telnet` on Debian trixie is a transitional package pulling `inetutils-telnet`; the command stays available.
- Moving to `ruby_node` adds a dependency edge (`rails_yarn` ← `ruby_node`); CircleCI `requires:` must reflect it so tag releases build in order.

## Benefits
- Current Ruby (3.4.12) and Node LTS (24) for Rails + Yarn consumers (and, next, `taa`/`taap`).
- One Node install in the hierarchy instead of two; smaller, failing-fast Dockerfiles.
- Up-to-date gems and front-end packages without breaking majors.
