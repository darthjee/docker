# rails_bower 1.6.0 on ruby_node 1.6.0
Create `rails_bower` 1.6.0 (+circleci/production), moving from `*ruby_node:1.5.0` to `*ruby_node:1.6.0` (`scripts:0.11.0` is unchanged), and ship a lockfile. Independent of steps 01–03.

1. `bin/script.sh init rails_bower 1.6.0`. Confirm that every `FROM` points at the `*ruby_node:1.6.0` variant and `scripts:0.11.0`.
2. Generate `home/Gemfile.lock` for each variant in its new parent image, seeded from the matching `ruby_331/1.2.0` lockfile (`ruby_node` installs no gems of its own).
3. Bundler subtests: dev and circleci use the plain `bundle check`. Change `production_rails_bower` to `BUNDLE_WITHOUT=development:test bundle check --gemfile=/home/app/app/Gemfile`. Its final stage already sets `ENV BUNDLE_WITHOUT development:test`, so this makes the scope explicit and consistent with `production_rails_yarn`.
4. Update the READMEs if they mention the old base versions. Build and test all three variants.

## Files to Change
- `rails_bower/1.6.0/`, `circleci_rails_bower/1.6.0/`, `production_rails_bower/1.6.0/` — new version folders (Dockerfile `FROM` updated)
- `*/1.6.0/home/Gemfile.lock` (the three rails_bower variants) — new lockfiles
- `production_rails_bower/1.6.0/test/subtests/bundler.sh` — explicitly scoped check
- `*/1.6.0/README.md` (the three rails_bower variants) — only if they reference the old bases
- `version` — rails_bower variants = 1.6.0
