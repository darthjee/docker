# rails_yarn 1.2.1 with Gemfile.lock
Create `rails_yarn` 1.2.1 (+circleci/production) on its current parents, which are already the newest: `ruby_331:1.2.0` / `circleci_ruby_331:1.2.0` / `production_ruby_331:1.2.0` and `scripts:0.11.0`. The only functional change is a shipped lockfile.

1. `bin/script.sh init rails_yarn` (defaults to 1.2.1 for all three variants; updates `version`).
2. Generate `home/Gemfile.lock` for each variant in its parent image, seeded from the matching `ruby_331/1.2.0` lockfile (see "Lockfile generation" in the index).
3. Bundler subtests: dev and circleci keep the plain `bundle check --gemfile=...`. Production keeps `BUNDLE_WITHOUT=development:test bundle check ...`.
4. Build and test all three variants.

## Files to Change
- `rails_yarn/1.2.1/`, `circleci_rails_yarn/1.2.1/`, `production_rails_yarn/1.2.1/` — new version folders (copied by `init`)
- `rails_yarn/1.2.1/home/Gemfile.lock`, `circleci_rails_yarn/1.2.1/home/Gemfile.lock`, `production_rails_yarn/1.2.1/home/Gemfile.lock` — new lockfiles
- `version` — `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn` = 1.2.1
