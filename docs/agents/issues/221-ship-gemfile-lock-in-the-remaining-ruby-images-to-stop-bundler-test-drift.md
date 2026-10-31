# Issue: Ship Gemfile.lock in the remaining Ruby images to stop bundler test drift

## Description
Found while refining #211. Ruby images that install gems ship only a `home/Gemfile`, with no `Gemfile.lock`. Their `bundler.sh` subtest runs `bundle check`, which re-resolves transitive dependencies against the current rubygems.org. Once a transitive gem publishes a new release, the check expects versions the image never installed and fails, even though the image did not change.

#211 fixed this for `ruby_331` (+circleci/production) and `rails_gems` (+circleci) by shipping a `Gemfile.lock` (`ruby_331` 1.1.2/1.2.0, `rails_gems` 2.1.2/2.2.0). The images below have the same risk.

## Problem
Affected images (all with circleci/production variants):

| Image | Latest version | Built on | Bundler subtest |
|---|---|---|---|
| `rails_yarn` | 1.2.0 | `ruby_331:1.2.0`, `scripts:0.11.0` | bare `bundle check` (production already scoped with `BUNDLE_WITHOUT=development:test`) |
| `taa` | 1.6.0 | `rails_yarn:1.2.0`, `scripts:0.11.0` | `bundle lock --local` workaround, then `bundle check` |
| `taap` | 1.5.0 | `taa:1.5.0`, `scripts:0.10.0` | bare `bundle check` |
| `rails_bower` | 1.5.0 | `ruby_node:1.5.0`, `scripts:0.11.0` | bare `bundle check`. `production_rails_bower` installs `without 'development test'` but its check is **not** scoped, which is the same bug #211 fixed for `production_ruby_331` |

Out of scope: `ruby_node` (+circleci/production). It installs no gems (no bundle step in its Dockerfile), its `home/Gemfile` is an unused copy of the `ruby_331` one, and its `bundler.sh` only prints versions, so it cannot drift.

## Expected Behavior
- Each affected image has a new version that ships a `home/Gemfile.lock` next to its `home/Gemfile`, so `bundle check` validates against the locked, installed gems and never resolves against the live index.
- `taa`'s bundler subtest drops the `bundle lock --local` workaround and goes back to a plain `bundle check`.
- `production_rails_bower`'s bundler subtest is scoped to the installed groups (`BUNDLE_WITHOUT=development:test bundle check ...`), matching `production_rails_yarn`.
- Each new version is built on the newest available parents, chained so that each child builds on the new version of its parent:
  - `rails_yarn` → on `ruby_331:1.2.0` / `scripts:0.11.0` (already the latest; only the lockfile changes)
  - `taa` → on the new `rails_yarn`
  - `taap` → on the new `taa` and `scripts:0.11.0` (moving off `taa:1.5.0` / `scripts:0.10.0`)
  - `rails_bower` → on `ruby_node:1.6.0` (+circleci/production) and `scripts:0.11.0`
- `bin/script.sh build <image>` builds all three variants of each image, and their tests pass.

## Solution
Follow the same approach as #211 for each image, in chain order (`rails_yarn` → `taa` → `taap`; `rails_bower` independently):

1. Create the new version (`bin/script.sh init <image>`), updating `FROM` lines to the newest parents listed above.
2. Generate `Gemfile.lock` inside each variant's own base image, using that image's actual bundler (dev/production use the image bundler; circleci uses the cimg bundler, to avoid a runtime auto-switch), restricted to `x86_64`/`aarch64` linux platforms so multi-arch builds work.
3. Update the bundler subtests as described above (`taa` workaround removed, `production_rails_bower` scoped).

Responsible agent: `ruby-node`.

## Benefits
- Bundler tests stop breaking when unrelated transitive gems publish new releases.
- Images are reproducible: the same versions are installed on every build and architecture.
- The whole Ruby+Node chain moves onto the current, multi-arch bases.
