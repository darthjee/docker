# circleci_node_mongo Dockerfile
Rebase onto `circleci_node:0.3.0`, move to series `9.0`, and pin both packages with the same values as `node_mongo`.

- `FROM darthjee/circleci_node:0.3.0`
- ARGs:
  ```dockerfile
  ARG MONGODB_SERIES=9.0
  ARG MONGOSH_VERSION=2.14.1
  ARG MONGODB_TOOLS_VERSION=100.20.1
  ```
- Keep the Ubuntu repo setup (`repo.mongodb.org/apt/ubuntu ${VERSION_CODENAME}/mongodb-org/${MONGODB_SERIES} multiverse`). It ships both packages for amd64 and arm64.
- Install `mongodb-mongosh=${MONGOSH_VERSION} mongodb-database-tools=${MONGODB_TOOLS_VERSION}`.
- Before relying on the apt route, check the Ubuntu codename of `cimg/node:22.23.4` (`. /etc/os-release`). Both noble and jammy carry the `9.0` packages today.
- Keep `USER circleci` at the end.

## Files to Change
- `circleci_node_mongo/0.3.0/Dockerfile` — new base, series, ARGs and pinned installs
