# Issue: Republish the Ruby image chain (ruby_331 → ruby_node / rails_yarn / rails_gems → taa) as multi-arch

## Description

Since #143, `bin/image.sh push` always releases with `docker buildx build --platform linux/amd64,linux/arm64`. But the Ruby image chain on Docker Hub was published before that change and is **amd64-only**, so no image built on it can be released for arm64. A buildx arm64 build fails on `FROM` because the base has no arm64 version.

Found while refining #202 (`taap` 1.5.0 on `taa:1.5.0`). It also affects #204 (`rails_bower` on `ruby_node:1.5.0`).

## Problem

Current state (Docker Hub architectures):

| Image | Built on | Architectures |
|---|---|---|
| `ruby_331:1.1.1` and its circleci/production versions | `ruby:3.3.1` / `cimg/ruby:3.3.1`, `scripts:0.7.0` | amd64 |
| `ruby_node:1.5.0` and its circleci/production versions | `ruby_331:1.1.1` and its circleci/production versions | amd64 |
| `rails_yarn:1.1.0` and its circleci/production versions | `ruby_331:1.1.1` and its circleci version, `scripts:0.8.0` | amd64 |
| `taa:1.5.0` and its circleci/production versions | `rails_yarn:1.1.0` and its circleci/production versions, `scripts:0.8.0` | amd64 |
| `rails_gems:2.1.1`, `circleci_rails_gems:2.1.1` | `ruby_331:1.1.1` and its circleci version, `scripts:0.7.0` | amd64 |
| `scripts:0.11.0` | — | amd64 + arm64 |

(`scripts:0.7.0` is amd64-only; `scripts:0.8.0` is listed as arm64-only.)

`production_rails_yarn` is built on `ruby_331` instead of `production_ruby_331`, which breaks the parallel-hierarchy convention.

## Expected Behavior

- Every image in the chain has a new **minor** version on Docker Hub with both `amd64` and `arm64`.
- Every rebuilt image uses `scripts:0.11.0`.
- `production_rails_yarn` is built on `production_ruby_331`.
- Building `taa` (all variants) with buildx for `linux/arm64` on the new bases succeeds.

## Solution

Bump every image in the chain to a new minor version with `bin/script.sh init`, which also moves its `FROM` tags to the new versions. Publish them in dependency order through the buildx multi-arch release:

| Order | Images | New version | Built on |
|---|---|---|---|
| 1 | `ruby_331`, `circleci_ruby_331`, `production_ruby_331` | `1.2.0` | `ruby:3.3.1` / `cimg/ruby:3.3.1`, `scripts:0.11.0` |
| 2 | `ruby_node`, `circleci_ruby_node`, `production_ruby_node` | `1.6.0` | matching `ruby_331` variant `1.2.0` |
| 2 | `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn` | `1.2.0` | matching `ruby_331` variant `1.2.0` (`production_rails_yarn` moves to `production_ruby_331`), `scripts:0.11.0` |
| 2 | `rails_gems`, `circleci_rails_gems` | `2.2.0` | matching `ruby_331` variant `1.2.0`, `scripts:0.11.0` |
| 3 | `taa`, `circleci_taa`, `production_taa` | `1.6.0` | matching `rails_yarn` variant `1.2.0`, `scripts:0.11.0` |

Update the `version` file with every new version.

Check on arm64 for every image: upstream bases (`ruby:3.3.1`, `cimg/ruby:3.3.1`), apt packages, NodeSource Node 22, and native gem extensions.

### Out of scope

`taap` and `rails_bower` (and their circleci/production versions) are not bumped here. Moving them to the new multi-arch bases is a follow-up.

### Responsible agents

`ruby` (`ruby_331`, `rails_gems` and their variants), `ruby-node` (`ruby_node`, `rails_yarn`, `taa` and their variants).

## Benefits

- The whole Ruby chain can be released for arm64, so downstream images (`taap`, `rails_bower`) can become multi-arch.
- All variants use the same, current `scripts` version.
- The production hierarchy is consistent with the development and CircleCI ones.
