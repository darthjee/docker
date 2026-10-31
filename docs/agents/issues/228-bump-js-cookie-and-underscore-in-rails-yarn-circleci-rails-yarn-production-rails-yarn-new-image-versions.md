# Issue: Bump js-cookie, underscore and jquery in rails_yarn / circleci_rails_yarn / production_rails_yarn (new image versions)

## Description

Dependabot opened #119, #120, #122 and #124 to bump `js-cookie` from 2.2.1 to 3.0.7. That release fixes CVE-2026-46625 (cookie attribute injection). They edit `home/package.json` in old version folders (`rails_yarn/1.0.1`, `rails_yarn/1.1.0`, `production_rails_yarn/1.0.1`, `production_rails_yarn/1.1.0`). Those versions are already released, and the `1.0.1` folders are gone from `main`. The PRs don't create a new image version, so they can't be merged as they are.

The same images also pin `underscore` 1.13.6. Dependabot flagged that version in `taa` (#117), so this issue bumps it to 1.13.8 too. `jquery` is also bumped from 3.6.1 to the latest 3.x (3.7.1) at the same time.

## Problem

The latest versions on `main` still pin the old versions:

| Image | Latest version | `js-cookie` | `underscore` | `jquery` |
|---|---|---|---|---|
| `rails_yarn` | 1.2.1 | 2.2.1 | 1.13.6 | 3.6.1 |
| `circleci_rails_yarn` | 1.2.1 | 2.2.1 | 1.13.6 | 3.6.1 |
| `production_rails_yarn` | 1.2.1 | 2.2.1 | 1.13.6 | 3.6.1 |

## Expected Behavior

- New **minor** version **1.3.0** for `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn`, created from 1.2.1 with `bin/script.sh init` / `update_deps`. The bump is minor, not patch, because js-cookie 3 is a major upgrade with API changes for downstream projects (for example, `Cookies.getJSON` was removed).
- `home/package.json` pins `js-cookie` to `3.0.7`, `underscore` to `1.13.8` and `jquery` to `3.7.1`. `yarn` and `bootstrap` (4.6.2, already the latest 4.x) stay the same.
- Base images unchanged (`scripts:0.11.0`, `ruby_331:1.2.0`, `circleci_ruby_331:1.2.0`, `production_ruby_331:1.2.0`). `Gemfile` / `Gemfile.lock` are carried over from 1.2.1 unchanged.
- `version` file updated: `rails_yarn=1.3.0`, `circleci_rails_yarn=1.3.0`, `production_rails_yarn=1.3.0`.
- Each new version has a `README.md` (see `docs/agents/image-readme.md`) that mentions the js-cookie major upgrade and the jquery bump.
- Image tests pass (`bin/script.sh test rails_yarn circleci_rails_yarn production_rails_yarn`).
- After merge, close #119, #120, #122 and #124 as superseded.

## Dependencies

- Blocks #229 (`taa` dependency bump; `taa` 1.6.1 is currently built on `rails_yarn:1.2.1`).
