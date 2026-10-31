# Ruby-Node Plan: Bump js-cookie, angular and underscore in taa / circleci_taa / production_taa (new image versions)

Main plan: [plan.md](plan.md)

## Overview
New minor version 1.7.0 for the three `taa` variants, rebased on `rails_yarn` 1.3.0, with updated JS package pins and READMEs.

## Context
- Current latest: `taa` / `circleci_taa` / `production_taa` **1.6.1**, `FROM darthjee/*rails_yarn:1.2.1` and `darthjee/scripts:0.11.0`.
- `taa/*/home/package.json` repeats every dependency that `rails_yarn` pins (`yarn`, `underscore`, `bootstrap`, `jquery`, `js-cookie`) and adds `angular`, `angular-route`, `cyberhawk`, `johto`. The repeated pins stay listed and must match `rails_yarn` 1.3.0 exactly (js-cookie 3.0.7, underscore 1.13.8, jquery 3.7.1, bootstrap 4.6.2, yarn 1.22.22).
- **Blocked by #228**: `bin/script.sh init` rewrites `FROM` lines from the `version` file, so `rails_yarn=1.3.0` (and the circleci_/production_ entries) must already be on the branch (merge `main` after #228 lands) before running it.

## Steps

- [01 — Create the 1.7.0 version folders](ruby-node/01-init-version.md)
- [02 — Bump package.json pins](ruby-node/02-bump-package-json.md)
- [03 — Update the READMEs](ruby-node/03-update-readmes.md)
- [04 — Build and test](ruby-node/04-build-and-test.md)

## CI Checks
- `taa`, `circleci_taa`, `production_taa`: `bin/script.sh build taa circleci_taa production_taa && bin/script.sh test taa circleci_taa production_taa`
- Release jobs `release-taa` / `release-circleci_taa` / `release-production_taa` in `.circleci/config.yml` already `require` the matching `release-*rails_yarn` job — no CI config change needed.

## Notes
- js-cookie 3 and angular 1.8 are breaking upgrades for downstream apps (e.g. `Cookies.getJSON` removed; angular `$http` `.success`/`.error` removed in 1.6+). That is why this is a minor bump, and the READMEs should mention it.
- `Gemfile` / `Gemfile.lock` are carried over from 1.6.1 unchanged. Only run `bin/script.sh update_deps taa rails_yarn` if #228 changed the rails_yarn Gemfile, which it is not expected to do.
- After merge, close Dependabot PRs #117, #118, #121 and #123 as superseded.
- Unblocks #230 (`taap` rebase onto `taa` 1.7.0).
