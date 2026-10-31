# Issue: Bump js-cookie, angular and underscore in taa / circleci_taa / production_taa (new image versions)

## Description

Dependabot opened these PRs against old, already-released `taa` version folders:

- #117: `underscore` 1.13.6 → 1.13.8 (`taa/1.5.0`)
- #118: `angular` 1.4.8 → 1.8.3 (`production_taa/1.5.0`)
- #121: `js-cookie` 2.2.1 → 3.0.7, which fixes CVE-2026-46625 (`circleci_taa/1.4.2`)
- #123: `js-cookie` 2.2.1 → 3.0.7 (`taa/1.4.2`)

None of them creates a new image version, so they can't be merged as they are.

## Problem

The latest versions on `main` still pin the old versions:

| Image | Latest version | Built on | `js-cookie` | `angular` / `angular-route` | `underscore` | `jquery` |
|---|---|---|---|---|---|---|
| `taa` | 1.6.1 | `rails_yarn:1.2.1` | 2.2.1 | 1.4.8 | 1.13.6 | 3.6.1 |
| `circleci_taa` | 1.6.1 | `circleci_rails_yarn:1.2.1` | 2.2.1 | 1.4.8 | 1.13.6 | 3.6.1 |
| `production_taa` | 1.6.1 | `production_rails_yarn:1.2.1` | 2.2.1 | 1.4.8 | 1.13.6 | 3.6.1 |

`taa`'s `home/package.json` also repeats every dependency that `rails_yarn` pins (`yarn`, `underscore`, `bootstrap`, `jquery`, `js-cookie`). Once #228 moves `rails_yarn` to 1.3.0 (js-cookie 3.0.7, underscore 1.13.8, jquery 3.7.1), these copies would fall out of step unless they are bumped too.

## Expected Behavior

- New **minor** version **1.7.0** for `taa`, `circleci_taa` and `production_taa`, created from **1.6.1** with `bin/script.sh init` / `update_deps`.
- `FROM` updated to `rails_yarn:1.3.0`, `circleci_rails_yarn:1.3.0` and `production_rails_yarn:1.3.0`. `scripts:0.11.0` stays the same.
- `home/package.json` pins:
  - `js-cookie` 3.0.7
  - `angular` 1.8.3 and **`angular-route` 1.8.3** (kept the same as `angular`)
  - `underscore` 1.13.8
  - `jquery` 3.7.1 (matching `rails_yarn` 1.3.0)
- The dependencies `taa` shares with `rails_yarn` (`yarn`, `underscore`, `bootstrap`, `jquery`, `js-cookie`) **stay listed** in `taa`'s `package.json`, pinned to exactly the same versions as `rails_yarn` 1.3.0. The `taa`-only dependencies (`cyberhawk`, `johto`) stay the same.
- `Gemfile` / `Gemfile.lock` are carried over from 1.6.1 unchanged.
- `version` file updated: `taa=1.7.0`, `circleci_taa=1.7.0`, `production_taa=1.7.0`.
- Each new version has a `README.md` (see `docs/agents/image-readme.md`) that mentions the js-cookie 3 and angular 1.8 upgrades and the jquery bump.
- Image tests pass (`bin/script.sh test taa circleci_taa production_taa`), and CI releases these images after `rails_yarn`.
- After merge, close #117, #118, #121 and #123 as superseded.

## Dependencies

- **Blocked by** #228 (rails_yarn 1.3.0).
- Blocks #230 (`taap` rebase).
