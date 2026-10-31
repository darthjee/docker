# taa 1.6.1 with Gemfile.lock and plain bundler checks
Create `taa` 1.6.1 (+circleci/production) on the new `rails_yarn` 1.2.1 variants and `scripts:0.11.0`, ship a lockfile, and remove the #212 offline-lock workarounds.

1. `bin/script.sh init taa` (only after step 01 has updated `version`). Confirm that every `FROM` now points at the `*rails_yarn:1.2.1` variant.
2. Generate `home/Gemfile.lock` for each variant in its new parent image, seeded from the matching `rails_yarn/1.2.1` lockfile.
3. Rewrite the bundler subtests:
   - `taa`: `bundle check --gemfile=/home/app/app/Gemfile` (drop `bundle lock --local` and its comment).
   - `circleci_taa`: `bundle check --gemfile=/home/circleci/project/Gemfile`.
   - `production_taa`: replace the reduced-Gemfile script with `BUNDLE_WITHOUT=development:test bundle check --gemfile=/home/app/app/Gemfile`.
4. Build and test all three variants.

## Files to Change
- `taa/1.6.1/`, `circleci_taa/1.6.1/`, `production_taa/1.6.1/` — new version folders
- `*/1.6.1/home/Gemfile.lock` (the three taa variants) — new lockfiles
- `taa/1.6.1/test/subtests/bundler.sh`, `circleci_taa/1.6.1/test/subtests/bundler.sh`, `production_taa/1.6.1/test/subtests/bundler.sh` — plain checks against the lockfile
- `version` — taa variants = 1.6.1
