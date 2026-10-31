# Build and test
Run `bin/script.sh test taap circleci_taap production_taap` and make sure all subtests pass (`bundler.sh`, `gems.sh`, `gnuplot.sh`, plus `user.sh` and `yarn_cache.sh` for circleci). The tests check package presence, not versions, so no test changes should be needed. If a test fails because of the new base (for example a changed yarn cache layout), fix the test in the 1.7.0 folder only.

If `darthjee/*taa:1.7.0` is not on Docker Hub yet, build those images locally first (`bin/script.sh build taa circleci_taa production_taa`, or whatever build command `bin/script.sh` offers).

## Files to Change
- `taap/1.7.0/test/**`, `circleci_taap/1.7.0/test/**`, `production_taap/1.7.0/test/**`: only if a test needs adjusting for the new base
