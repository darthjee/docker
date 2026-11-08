# Build and test
1. If any of `darthjee/{,circleci_,production_}{ruby_node,rails_yarn,taa}:2.0.0` cannot be pulled from Docker Hub, build it locally first (`bin/image.sh build <image>`, which also tags `:2.0.0`).
   - Build order: `ruby_node` → `rails_yarn` → `taa`.
   - Repeat for each architecture tested.
2. For each of `taap`, `circleci_taap` and `production_taap`, on `linux/amd64` and on `linux/arm64`:
   - Run `PLATFORM=linux/<arch> bin/image.sh build <image>`, then `PLATFORM=linux/<arch> bin/image.sh test <image>`.
   - Keep the existing subtests and add no new ones.
3. Spot-check in the dev image:
   - `ruby -v` is 3.4.12.
   - `node -v` is v24.
   - `gnuplot --version` works.
   - `bundle check` passes.
   - `ruby -e 'require "danica"; require "gnuplot"'` succeeds.
4. Delta rule: check that the image's bundle delta contains only danica, gnuplot and their new dependencies, with no gem shared with `taa` duplicated.

## Files to Change
- none (verification only)
