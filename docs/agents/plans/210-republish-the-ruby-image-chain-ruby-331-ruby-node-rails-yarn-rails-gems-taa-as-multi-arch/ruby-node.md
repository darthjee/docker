# Ruby-Node Plan: Republish the Ruby image chain (ruby_331 → ruby_node / rails_yarn / rails_gems → taa) as multi-arch

Main plan: [plan.md](plan.md)

## Shared contracts

Wait for `ruby` to produce `ruby_331`, `circleci_ruby_331`, `production_ruby_331` `1.2.0` (in the `version` file and built locally) before running any `init`. Produce `ruby_node` 1.6.0, `rails_yarn` 1.2.0 and `taa` 1.6.0, all variants.

## Steps

- [01 — ruby_node 1.6.0](ruby-node/01-ruby-node-1-6-0.md)
- [02 — rails_yarn 1.2.0](ruby-node/02-rails-yarn-1-2-0.md)
- [03 — taa 1.6.0](ruby-node/03-taa-1-6-0.md)

## CI Checks
- Local: `bin/script.sh build <images>` and `bin/script.sh test <images>` (these exit non-zero on failure since #205)
- Release (on tag): CircleCI `release-ruby_node`, `release-rails_yarn`, `release-taa` jobs (and their circleci/production counterparts), multi-arch buildx

## Notes
- `taap` and `rails_bower` are out of scope. Don't move them to the new bases.
- Don't delete the old version folders.
- For every image, check arm64 with `docker buildx build --platform linux/arm64`: NodeSource `setup_22.x`, apt packages, Yarn, and native gem extensions.
