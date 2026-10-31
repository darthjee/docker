# Add rails_yarn 1.1.1 images
The published `darthjee/{,circleci_,production_}rails_yarn:1.1.0` images don't match the repo's `home/Gemfile`. `bundle check` reports missing runtime gems (execjs, json, i18n, zeitwerk, sprockets, ...). Ship a 1.1.1 built from the current Gemfile:

1. Run `bin/script.sh init rails_yarn 1.1.1`, `bin/script.sh init circleci_rails_yarn 1.1.1` and `bin/script.sh init production_rails_yarn 1.1.1`, or copy the 1.1.0 folders if `init` doesn't fit. Update the three entries in `version` to `1.1.1`.
2. In each 1.1.1 `home/Gemfile`, remove the second `gem 'rubocop-rspec', '3.9.0'` line (Bundler warns about the duplicate).
3. **production_rails_yarn 1.1.1:** add `ENV BUNDLE_WITHOUT development:test` to the final stage of the Dockerfile, as production_rails_bower 1.5.0 does (#204). Change `test/subtests/bundler.sh` to `BUNDLE_WITHOUT=development:test bundle check --gemfile=/home/app/app/Gemfile`.
4. Update any version references in the 1.1.1 READMEs that `init` doesn't handle. Per #173, READMEs carry no hardcoded version tags.
5. Run `bin/script.sh build rails_yarn` (builds all three variants), then `bin/script.sh test rails_yarn`.

Leave the taa images on `rails_yarn:1.1.0`.

## Files to Change
- `rails_yarn/1.1.1/**`, `circleci_rails_yarn/1.1.1/**`, `production_rails_yarn/1.1.1/**`: new version folders (Dockerfile, home/Gemfile, home/package.json, README.md, test/).
- `production_rails_yarn/1.1.1/Dockerfile`: add `ENV BUNDLE_WITHOUT development:test` to the final stage.
- `production_rails_yarn/1.1.1/test/subtests/bundler.sh`: add `BUNDLE_WITHOUT=development:test`.
- `version`: set `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn` to `1.1.1`.
