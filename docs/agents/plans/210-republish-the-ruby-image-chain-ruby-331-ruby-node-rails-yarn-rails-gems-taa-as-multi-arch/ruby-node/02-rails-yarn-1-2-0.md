# rails_yarn 1.2.0
Run `bin/script.sh init rails_yarn 1.2.0`. Check that `FROM` now points to `darthjee/scripts:0.11.0` and the matching `ruby_331` variant `1.2.0`. Then change `production_rails_yarn/1.2.0/Dockerfile` by hand from `FROM darthjee/ruby_331:1.2.0` to `FROM darthjee/production_ruby_331:1.2.0`, to follow the parallel-hierarchy convention. Make sure the production image still has everything its stages need. Development tooling it used to inherit from `ruby_331` may now be missing; install only what's actually required. Check that the scripts the Dockerfiles copy or source from the `scripts` stage still work with `0.11.0` (compare with `scripts/0.8.0`). Update the READMEs, then build, test, and check arm64 for all three variants.

## Files to Change
- `rails_yarn/1.2.0/**`, `circleci_rails_yarn/1.2.0/**`, `production_rails_yarn/1.2.0/**` — new versions created by `init`
- `production_rails_yarn/1.2.0/Dockerfile` — base moved to `production_ruby_331:1.2.0`
- `version` — `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn` → `1.2.0`
