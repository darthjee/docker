# Create the 1.7.0 version folders
Run `bin/script.sh init taap 1.7.0` from the repo root. It creates `taap/1.7.0`, `circleci_taap/1.7.0` and `production_taap/1.7.0` from 1.6.0 and sets `taap=1.7.0`, `circleci_taap=1.7.0`, `production_taap=1.7.0` in `version`. It also rewrites the `FROM` lines.

Then check:
- each new `Dockerfile` has `FROM darthjee/scripts:0.11.0 as scripts` and `FROM darthjee/<variant>taa:1.7.0 as base`;
- `home/Gemfile` and `home/Gemfile.lock` match 1.6.0, and `diff <variant>taap/1.7.0/home/Gemfile.lock <variant>taa/1.7.0/home/Gemfile.lock` shows only `danica` / `gnuplot` entries (and their dependency lines). If more shows up, re-resolve the lock against the 1.7.0 base so it stays a pure delta.

Do not change the 1.6.0 (or older) folders.

## Files to Change
- `version`: `taap`, `circleci_taap` and `production_taap` set to `1.7.0`
- `taap/1.7.0/**`: new, copied from 1.6.0, `FROM darthjee/taa:1.7.0`
- `circleci_taap/1.7.0/**`: new, copied from 1.6.0, `FROM darthjee/circleci_taa:1.7.0`
- `production_taap/1.7.0/**`: new, copied from 1.6.0, `FROM darthjee/production_taa:1.7.0`
