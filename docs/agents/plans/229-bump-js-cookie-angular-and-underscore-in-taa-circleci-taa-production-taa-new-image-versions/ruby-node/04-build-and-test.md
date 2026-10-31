# Build and test
Build `rails_yarn` 1.3.0 locally if it isn't published yet, then run `bin/script.sh build taa circleci_taa production_taa` and `bin/script.sh test taa circleci_taa production_taa`. Both must exit 0. The bundler subtest must pass, which confirms that Gemfile.lock didn't drift. If `yarn_builder.sh` fails to resolve the new pins, check the cache seeding in the circleci Dockerfile (#217) before changing any pins.

## Files to Change
- None expected. Only fix files from steps 01–03 if the build or tests show a problem.
