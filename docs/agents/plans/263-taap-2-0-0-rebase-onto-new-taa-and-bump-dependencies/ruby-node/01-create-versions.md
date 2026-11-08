# Create the 2.0.0 versions
1. For each of `taap`, `circleci_taap` and `production_taap`, run `bin/script.sh init <image> 2.0.0` to copy the latest version (1.7.0) into `<image>/2.0.0/`.
2. In the `version` file, set `taap=2.0.0`, `circleci_taap=2.0.0` and `production_taap=2.0.0`.

## Files to Change
- `version`
- `{,circleci_,production_}taap/2.0.0/**` (new, copied from 1.7.0)
