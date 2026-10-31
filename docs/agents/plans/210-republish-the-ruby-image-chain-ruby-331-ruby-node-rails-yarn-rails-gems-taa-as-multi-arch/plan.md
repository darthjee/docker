# Plan: Republish the Ruby image chain (ruby_331 → ruby_node / rails_yarn / rails_gems → taa) as multi-arch

Issue: [210-republish-the-ruby-image-chain-ruby-331-ruby-node-rails-yarn-rails-gems-taa-as-multi-arch.md](../../issues/210-republish-the-ruby-image-chain-ruby-331-ruby-node-rails-yarn-rails-gems-taa-as-multi-arch.md)

## Overview
Scaffold a new minor version of every image in the Ruby chain with `bin/script.sh init`, so each one moves to `scripts:0.11.0` and to the new versions of its bases. Fix `production_rails_yarn` to build on `production_ruby_331`. The tag-triggered CircleCI `release` workflow already publishes images in dependency order with `docker buildx --platform linux/amd64,linux/arm64`, so publishing the new versions makes the chain multi-arch. `taap` and `rails_bower` are out of scope.

## Agents involved

- [ruby](ruby.md)
- [ruby-node](ruby-node.md)

## Shared contracts

`ruby` produces, and `ruby-node` consumes:

| Image | New version | `FROM` |
|---|---|---|
| `ruby_331` | `1.2.0` | `darthjee/scripts:0.11.0`, `ruby:3.3.1` |
| `circleci_ruby_331` | `1.2.0` | `darthjee/scripts:0.11.0`, `cimg/ruby:3.3.1` |
| `production_ruby_331` | `1.2.0` | `darthjee/scripts:0.11.0`, `ruby:3.3.1` |

- The `version` file must list `ruby_331=1.2.0`, `circleci_ruby_331=1.2.0` and `production_ruby_331=1.2.0` **before** `ruby-node` runs `bin/script.sh init`, because `init` reads the `version` file to rewrite `FROM darthjee/<image>:<tag>` lines.
- `ruby-node` needs the three `ruby_331:1.2.0` images built locally (`bin/script.sh build`) to build and test its own images.
- Order: `ruby` step 01 (`ruby_331`) → `ruby-node` steps. `ruby` step 02 (`rails_gems`) is independent of `ruby-node`.
- New versions owned by `ruby-node`: `ruby_node` (all variants) `1.6.0`, `rails_yarn` (all variants) `1.2.0`, `taa` (all variants) `1.6.0`. New version owned by `ruby`: `rails_gems` / `circleci_rails_gems` `2.2.0`.
