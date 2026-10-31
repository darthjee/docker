# Release circleci_taap 1.5.1
Create the version with `bin/script.sh init circleci_taap 1.5.1`. This image has no yarn step, so it only needs rebuilding on the fixed `circleci_taa`.

- Bump `FROM darthjee/circleci_taa:1.5.0` → `darthjee/circleci_taa:1.5.1`, and `FROM darthjee/scripts:0.10.0` → `darthjee/scripts:0.11.0`.
- Tests: add `test/subtests/yarn_cache.sh`, checking that `yarn cache dir` is `/home/circleci/.cache/yarn/v6` and that the cache is non-empty. There is no `home/package.json` here, so check a few known inherited packages (e.g. one from `circleci_taa` and one from `circleci_rails_yarn`) instead of iterating a `package.json`. Also add `test/subtests/user.sh`.
- README: replace `/usr/local/share/.cache/yarn/v6` with `/home/circleci/.cache/yarn/v6` in the "Pre-installed gems and pre-cached packages" section.

## Files to Change
- `circleci_taap/1.5.1/Dockerfile` — new bases
- `circleci_taap/1.5.1/test/subtests/yarn_cache.sh` — new cache test
- `circleci_taap/1.5.1/test/subtests/user.sh` — new user test
- `circleci_taap/1.5.1/README.md` — cache location
- `version` — `circleci_taap=1.5.1` (done by `init`)
