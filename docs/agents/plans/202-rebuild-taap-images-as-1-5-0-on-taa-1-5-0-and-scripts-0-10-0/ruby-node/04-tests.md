# Rewrite the tests

For each 1.5.0 variant, under `test/`:

- `test/test.sh`: keep the canonical runner copied from 1.4.2 (runs every `subtests/*.sh` and exits 1 if any fails).
- `subtests/bundler.sh`: `bundle check` against that variant's Gemfile, at the path where `Dockerfile.test` copies `home/` (the image's `WORKDIR`):
  - `taap`, `production_taap`: `bundle check --gemfile=/home/app/app/Gemfile`
  - `circleci_taap`: `bundle check --gemfile=/home/circleci/project/Gemfile` (1.4.2 wrongly used `/home/app/app`)
- New `subtests/gems.sh`: `ruby -e 'require "danica"; require "gnuplot"'`
- New `subtests/gnuplot.sh`: `gnuplot --version`
- Delete `subtests/node.sh` and `test/test.js`: `taap` has no JS of its own.

## Files to Change
- `{,circleci_,production_}taap/1.5.0/test/subtests/bundler.sh` — correct Gemfile path per variant
- `{,circleci_,production_}taap/1.5.0/test/subtests/gems.sh` — new
- `{,circleci_,production_}taap/1.5.0/test/subtests/gnuplot.sh` — new
- `{,circleci_,production_}taap/1.5.0/test/subtests/node.sh` — delete
- `{,circleci_,production_}taap/1.5.0/test/test.js` — delete
