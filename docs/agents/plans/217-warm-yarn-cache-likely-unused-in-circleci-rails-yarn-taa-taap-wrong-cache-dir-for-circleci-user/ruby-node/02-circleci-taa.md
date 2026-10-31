# Release circleci_taa 1.5.1
Create the version with `bin/script.sh init circleci_taa 1.5.1`.

- Bump `FROM darthjee/scripts:0.8.0` → `darthjee/scripts:0.11.0` and `FROM darthjee/circleci_rails_yarn:1.1.0` → `darthjee/circleci_rails_yarn:1.1.1`.
- Builder stage: `yarn_builder.sh` dedupes against the **root** cache (`/usr/local/share/.cache/yarn/v6`). On the fixed base that cache is empty, because the inherited packages now live in `/home/circleci/.cache/yarn/v6`. Before `RUN /bin/bash yarn_builder.sh`, seed the root cache from the inherited one (e.g. `RUN mkdir -p /usr/local/share/.cache/yarn/v6 && cp -R /home/circleci/.cache/yarn/v6/. /usr/local/share/.cache/yarn/v6/`, as root). Then the inherited packages are not re-downloaded and not duplicated into `yarn/new/`.
- Final stage: change the yarn `COPY` target to `/home/circleci/.cache/yarn/v6/`, with `--chown=circleci:circleci`. It merges into the inherited cache dir.
- Fix the stray `USER app` at the end of the builder stage, as in step 01.
- Tests: add `test/subtests/yarn_cache.sh` and `test/subtests/user.sh`, as in step 01. The cache test checks this image's `home/package.json` packages. Also check that one `circleci_rails_yarn` package is still present, so the merge didn't replace the inherited cache.
- README: if it mentions the cache location, state `/home/circleci/.cache/yarn/v6/`.

## Files to Change
- `circleci_taa/1.5.1/Dockerfile` — new bases, root-cache seeding in the builder, new cache target, builder `USER` cleanup
- `circleci_taa/1.5.1/test/subtests/yarn_cache.sh` — new cache test
- `circleci_taa/1.5.1/test/subtests/user.sh` — new user test
- `circleci_taa/1.5.1/README.md` — cache location, if mentioned
- `version` — `circleci_taa=1.5.1` (done by `init`)
