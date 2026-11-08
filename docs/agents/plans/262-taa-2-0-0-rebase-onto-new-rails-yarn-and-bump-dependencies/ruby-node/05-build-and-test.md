# Build and test
1. If `darthjee/{,circleci_,production_}ruby_node:2.0.0` or `darthjee/{,circleci_,production_}rails_yarn:2.0.0` are not pullable from Docker Hub, build them locally first (`bin/image.sh build <image>` then tag `:2.0.0`), `ruby_node` before `rails_yarn`, for each architecture tested.
2. For each of `taa`, `circleci_taa`, `production_taa`, on `linux/amd64` and `linux/arm64`: `PLATFORM=linux/<arch> bin/image.sh build <image>` then `PLATFORM=linux/<arch> bin/image.sh test <image>`. Existing subtests are kept; no new subtests.
3. Spot-check in the dev image: `ruby -v` is 3.4.12, `node -v` is v24, `yarn -v` is 1.22.22, `bundle check` passes, and the yarn cache contains `js-cookie-3.0.8`.
4. Check that no gem shared with `rails_yarn` was duplicated in the image's bundle folder (delta rule).

## Files to Change
- none (verification only)
