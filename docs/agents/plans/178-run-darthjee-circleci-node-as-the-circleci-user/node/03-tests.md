# Add tests
Add `circleci_node/0.2.3/test/`, following the `circleci_taa/1.5.0/test` layout.

**Custom test Dockerfile is required.** The shared `Dockerfile.test` ends with `USER $USER_NAME` (= `circleci`), which would make a `whoami` check pass even on the current root image. `bin/image.sh test` uses `<image>/<version>/test/Dockerfile` when it exists, so add one that does **not** override the user:

```dockerfile
ARG DOCKER_ID_USER
ARG IMAGE
ARG VERSION

FROM $DOCKER_ID_USER/$IMAGE:$VERSION

ARG IMAGE
ARG VERSION

COPY --chown=circleci:circleci $IMAGE/$VERSION/home ./
COPY --chown=circleci:circleci $IMAGE/$VERSION/test /home/test
```

Files:
- `test/Dockerfile` — above.
- `test/test.sh` — same runner as `circleci_taa/1.5.0/test/test.sh` (runs every `subtests/*.sh`, counts failures, exits non-zero on any failure).
- `test/subtests/user.sh` — fails unless `whoami` is `circleci`.
- `test/subtests/yarn_cache.sh`:
  - fails unless `yarn cache dir` equals `/home/circleci/.cache/yarn/v6`;
  - fails unless the cache is non-empty and contains an entry for every dependency/devDependency name in `/home/circleci/project/package.json`. For example, check each name against `yarn cache list` output (or against `npm-<name>-*` folders in the cache dir). Use `node -e` to read the names from `package.json`.
  - Optionally, run `yarn install --offline --ignore-scripts` in a temp copy of the project to prove the cache resolves without the network.

Make sure `test.sh` and the subtests are executable (match the mode used in `circleci_taa`).

## Files to Change
- `circleci_node/0.2.3/test/Dockerfile` — new, keeps the image's runtime user
- `circleci_node/0.2.3/test/test.sh` — new runner
- `circleci_node/0.2.3/test/subtests/user.sh` — new
- `circleci_node/0.2.3/test/subtests/yarn_cache.sh` — new
