# Issue: Rebuild taap / circleci_taap / production_taap on taa 1.7.0 (new image versions)

## Description

Dependabot opened these PRs against old, already-released `taap` version folders:

- #125: `js-cookie` 2.2.1 → 3.0.7, which fixes CVE-2026-46625 (`production_taap/1.4.2`)
- #138: `angular` 1.4.8 → 1.8.3 (`taap/1.4.2`)

Since 1.5.0, `taap` no longer has its own `package.json`. It inherits its JS dependencies from `taa`. #229 delivered `taa` / `circleci_taa` / `production_taa` 1.7.0 with these bumps, so the fix reaches `taap` by rebuilding it on `taa` 1.7.0.

## Problem

| Image | Latest version (published) | Built on |
|---|---|---|
| `taap` | 1.6.0 | `taa:1.6.1` |
| `circleci_taap` | 1.6.0 | `circleci_taa:1.6.1` |
| `production_taap` | 1.6.0 | `production_taa:1.6.1` |

The 1.6.0 versions were added by #221 (shipping `Gemfile.lock`) and are already on Docker Hub, so they can't be changed in place. Their `taa` 1.6.1 base still has `js-cookie` 2.2.1 and `angular` 1.4.8.

## Expected Behavior

- New **minor** version **1.7.0** for `taap`, `circleci_taap` and `production_taap`, which matches `taa` 1.7.0. The inherited angular 1.4→1.8 and js-cookie 2→3 upgrades are breaking for downstream apps, so a minor bump is right.
- Create the new folders with `bin/script.sh init` / `update_deps`, starting from 1.6.0 (so the `Gemfile.lock` is kept).
- `FROM` updated to `darthjee/taa:1.7.0`, `darthjee/circleci_taa:1.7.0` and `darthjee/production_taa:1.7.0`. Keep `scripts:0.11.0`.
- `Gemfile.lock` regenerated or checked against the `taa` 1.7.0 base, so it stays a pure delta.
- `version` file updated: `taap=1.7.0`, `circleci_taap=1.7.0`, `production_taap=1.7.0`.
- Each new version has a `README.md` (see `docs/agents/image-readme.md`) with a short note that the angular 1.8 / js-cookie 3 / jquery upgrades come from `taa` 1.7.0, plus a link to the matching `taa` README.
- Image tests pass (`bin/script.sh test taap circleci_taap production_taap`), and CI releases these images after `taa` 1.7.0.
- After merge, close #125 and #138 as superseded.

## Dependencies

- Depends on #229 (`taa` 1.7.0). It is merged, but `taa:1.7.0` must be published to Docker Hub before the `taap` images can build in CI.
