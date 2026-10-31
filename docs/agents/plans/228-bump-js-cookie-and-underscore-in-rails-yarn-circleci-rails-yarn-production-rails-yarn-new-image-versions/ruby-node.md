# Plan: Bump js-cookie, underscore and jquery in rails_yarn / circleci_rails_yarn / production_rails_yarn (new image versions)

Issue: [228-bump-js-cookie-and-underscore-in-rails-yarn-circleci-rails-yarn-production-rails-yarn-new-image-versions.md](../../issues/228-bump-js-cookie-and-underscore-in-rails-yarn-circleci-rails-yarn-production-rails-yarn-new-image-versions.md)

## Overview
Create version 1.3.0 of the three `rails_yarn` variants from 1.2.1 and bump three front-end packages in each `home/package.json`. Base images, `Gemfile` / `Gemfile.lock`, tests and every other dependency stay as they are in 1.2.1.

## Context
- The latest version on `main` is 1.2.1 for all three variants. 1.2.1 pins `js-cookie` 2.2.1, `underscore` 1.13.6 and `jquery` 3.6.1, and `yarn` 1.22.22 and `bootstrap` 4.6.2 (these two stay).
- The Dependabot PRs edit already-released folders (`1.0.1` / `1.1.0`), so they can't be merged.
- The bump is **minor** (1.3.0), not patch: js-cookie 3 is a major upgrade with API changes for downstream projects (for example, `Cookies.getJSON` was removed).
- `taa` 1.6.1 is built on `rails_yarn:1.2.1`. Rebasing it is #229's job, not this issue's.

## Implementation Steps

### Step 1 — Scaffold 1.3.0 and bump the packages
1. Run `bin/script.sh init rails_yarn 1.3.0`. It copies `1.2.1` → `1.3.0` for `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn`, updates the `version` file (`*rails_yarn=1.3.0`) and refreshes the `darthjee/*` `FROM` tags from `version`. Check that the Dockerfiles still read `scripts:0.11.0` and `ruby_331:1.2.0` / `circleci_ruby_331:1.2.0` / `production_ruby_331:1.2.0`. These are already the current versions, so nothing should change.
2. In each of the three `1.3.0/home/package.json` files, set `"js-cookie": "3.0.7"`, `"underscore": "1.13.8"` and `"jquery": "3.7.1"`. Leave `yarn` and `bootstrap` untouched. `bin/script.sh update_deps` only syncs `Gemfile` versions, so make these edits by hand and keep the three files identical.
3. Leave `Gemfile` / `Gemfile.lock` as copied from 1.2.1.

### Step 2 — READMEs and verification
1. Update each `1.3.0/README.md` following `docs/agents/image-readme.md`. Add a short note that this version ships `js-cookie` 3 (a major upgrade with API changes, such as `Cookies.getJSON` being removed; see the js-cookie 3 migration notes) and `jquery` 3.7. The pre-cached package list itself doesn't change.
2. Run `bin/script.sh test rails_yarn circleci_rails_yarn production_rails_yarn` and make sure all three pass. That includes the circleci `yarn_cache.sh` / `user.sh` subtests and the `node.sh` subtest. Fix any subtest that hard-codes the old package versions.

## Files to Change
- `rails_yarn/1.3.0/**`, `circleci_rails_yarn/1.3.0/**`, `production_rails_yarn/1.3.0/**`: new version folders (copied by `init`). `home/package.json` gets the bumps and `README.md` gets the upgrade note.
- `version`: `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn` go to `1.3.0`.

## CI Checks
- `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn`: `bin/script.sh test rails_yarn circleci_rails_yarn production_rails_yarn` (CI jobs: `release-rails_yarn`, `release-circleci_rails_yarn`, `release-production_rails_yarn` in `.circleci/config.yml`)

## Notes
- After merge, close #119, #120, #122 and #124 as superseded. They target released (or deleted) version folders.
- Don't touch `taa` / `taap` here. #229 rebases `taa` onto `rails_yarn:1.3.0`.
- Existing 1.2.1 and older folders stay unchanged.
