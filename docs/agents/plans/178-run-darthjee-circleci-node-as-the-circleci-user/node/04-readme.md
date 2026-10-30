# Update the README
In `circleci_node/0.2.3/README.md` (follow `docs/agents/image-readme.md`):
- State that the image runs as the `circleci` user, with working directory `/home/circleci/project`.
- Change the cache location in "Pre-cached packages" from `/usr/local/share/.cache/yarn/v6/` to `/home/circleci/.cache/yarn/v6/`. Say that it is yarn's default cache dir for `circleci`, so nothing has to be configured.
- In "How to use" (the base-image example), mention that child Dockerfiles run as `circleci` and need `USER root` for system-level installs (as `circleci_node_mongo` does).

## Files to Change
- `circleci_node/0.2.3/README.md` — runtime user and cache location
