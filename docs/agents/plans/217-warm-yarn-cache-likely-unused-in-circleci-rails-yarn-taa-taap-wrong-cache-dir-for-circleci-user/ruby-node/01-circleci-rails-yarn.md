# Fix circleci_rails_yarn 1.2.0 in place
Versions created after this plan was first written (by #210) are not yet published on Docker Hub, so this is a **fix in place** of the current unpublished version: do not run `bin/script.sh init`, and leave `version` unchanged. `1.2.0` already uses `darthjee/scripts:0.11.0` and `darthjee/circleci_ruby_331:1.2.0`; `1.1.0`/`1.1.1` stay untouched.

- In the base stage, while still `USER root`, create `/home/circleci/.cache/yarn` and `chown circleci:circleci` it (as in `circleci_node/0.2.3`), so the final `COPY` does not leave a root-owned `.cache` parent.
- Final stage: change the yarn `COPY` target to `/home/circleci/.cache/yarn/v6/`, keeping `--chown=circleci:circleci`.
- Fix the stray `USER app` at the end of the builder stage (no `app` user exists in this image; it is harmless only because the final stage starts fresh). Drop it or switch it to `USER circleci`.
- Use `ENV KEY=value` syntax for the touched `ENV` lines, matching `circleci_node/0.2.3`. This is optional cleanup.
- Tests: add `test/subtests/yarn_cache.sh` (adapted from `circleci_node/0.2.3/test/subtests/yarn_cache.sh`, checking that `yarn cache dir` is `/home/circleci/.cache/yarn/v6` and that every dependency in `/home/circleci/project/package.json` is cached there) and `test/subtests/user.sh` (runs as `circleci`). Check that the test harness copies `home/` to `/home/circleci/project` (via `Dockerfile.test`, or add a `test/Dockerfile` like `circleci_node/0.2.3/test/Dockerfile`).
- README: state that the packages are pre-cached in `/home/circleci/.cache/yarn/v6/`, yarn's default cache dir for the `circleci` user (the base-image wording already says `darthjee/circleci_ruby_331` in 1.2.0).

## Files to Change
- `circleci_rails_yarn/1.2.0/Dockerfile` — cache dir creation, new cache target, builder `USER` cleanup
- `circleci_rails_yarn/1.2.0/test/subtests/yarn_cache.sh` — new cache test
- `circleci_rails_yarn/1.2.0/test/subtests/user.sh` — new user test
- `circleci_rails_yarn/1.2.0/test/Dockerfile` — only if the default `Dockerfile.test` doesn't place `home/` where the cache test expects it
- `circleci_rails_yarn/1.2.0/README.md` — cache location
