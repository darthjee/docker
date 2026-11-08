# READMEs, build and test
- Update `node/0.3.0/README.md` and `circleci_node/0.3.0/README.md` following `docs/agents/image-readme.md`:
  - the version and tags;
  - the base image (`node:22.23.4` / `cimg/node:22.23.4`);
  - the scripts version;
  - the package list with the new versions.
- Build both images: `bin/script.sh build node` and `bin/script.sh build circleci_node`. Check that `arm64` builds too, with `bin/script.sh build <image> arm64` or `buildx`.
- Run `bin/script.sh test circleci_node`. The `yarn_cache.sh` subtest checks that every `package.json` entry is cached and that `yarn install --offline` works. `node` has no tests, so a successful build is enough.

## Files to Change
- `node/0.3.0/README.md` — refreshed for 0.3.0.
- `circleci_node/0.3.0/README.md` — refreshed for 0.3.0.
