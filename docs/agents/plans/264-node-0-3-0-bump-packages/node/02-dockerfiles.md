# Update the Dockerfiles
In both `0.3.0` Dockerfiles:

- `FROM darthjee/scripts:0.11.0 as scripts` → `FROM darthjee/scripts:0.15.0 AS scripts`.
- Pin the base images to the same Node 22 patch (latest found: **22.23.4**, on both `node` and `cimg/node`):
  - `node`: `FROM node:22 as base` → `FROM node:22.23.4 AS base`.
  - `circleci_node`: `FROM cimg/node:22.14.0 as base` → `FROM cimg/node:22.23.4 AS base`.
- Use uppercase `AS` for every stage (`builder` too), as in the 2.0.0 images.

Before pinning, check that both tags exist and have `linux/amd64` and `linux/arm64` manifests (`docker buildx imagetools inspect <tag>`). If `cimg/node` has no arm64 build for that patch, use the newest 22.x patch that both images publish for both architectures.

Nothing else in the build changes. The `yarn_builder.sh` stage and the final `COPY` of the yarn cache stay as they are.

## Files to Change
- `node/0.3.0/Dockerfile` — scripts 0.15.0, `node:22.23.4`, uppercase `AS`.
- `circleci_node/0.3.0/Dockerfile` — scripts 0.15.0, `cimg/node:22.23.4`, uppercase `AS`.
