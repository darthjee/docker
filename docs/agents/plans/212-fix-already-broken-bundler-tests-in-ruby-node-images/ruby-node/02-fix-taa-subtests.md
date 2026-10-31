# Fix circleci_taa and production_taa bundler subtests
- **circleci_taa:** the subtest checks `/home/circleci/app/Gemfile`, but circleci images copy `home/` to `/home/circleci/project`, as circleci_taap 1.5.0 does. Change the path to `/home/circleci/project/Gemfile`.
- **production_taa:** `bundle check` reports 31 missing development/test gems, which the production image leaves out on purpose. Use the same command as production_taap 1.5.0:

  ```bash
  BUNDLE_WITHOUT=development:test bundle check --gemfile=/home/app/app/Gemfile
  ```

Both are test-only changes, so the version stays 1.5.0. If production_taa still fails after the change, the remaining missing gems are runtime gems. That means the published image is out of date, and fixing it needs a new image version. Report it rather than bumping silently.

## Files to Change
- `circleci_taa/1.5.0/test/subtests/bundler.sh`: change the Gemfile path to `/home/circleci/project/Gemfile`.
- `production_taa/1.5.0/test/subtests/bundler.sh`: add `BUNDLE_WITHOUT=development:test`.
