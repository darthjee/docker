# Build, test, and update docs and versions
Build and test all three variants (`bin/script.sh build/test`, or `run_checks.sh ruby-node`). Bump the `version` file entries `rails_bower`, `circleci_rails_bower` and `production_rails_bower` to 2.0.0. In each 2.0.0 README, call out the breaking changes: Rails 7.0 → 7.2, plus major jumps for rubocop (1.59 → 1.85), rubocop-rspec (2 → 3) and sinclair (2 → 3), and any other bumped pin. Downstream projects may need changes to upgrade.

## Files to Change
- `version`: the rails_bower variants go to 2.0.0
- `rails_bower/2.0.0/README.md`, `circleci_rails_bower/2.0.0/README.md`, `production_rails_bower/2.0.0/README.md`: breaking-change notes
