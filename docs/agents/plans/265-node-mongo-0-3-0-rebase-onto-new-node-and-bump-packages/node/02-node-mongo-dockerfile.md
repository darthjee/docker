# node_mongo Dockerfile
Rebase onto `node:0.3.0`, move to series `9.0`, and pin both MongoDB packages.

- `FROM darthjee/node:0.3.0`
- ARGs:
  ```dockerfile
  ARG MONGODB_SERIES=9.0
  ARG MONGOSH_VERSION=2.14.1
  ARG MONGODB_TOOLS_VERSION=100.20.1
  ```
- Keep the current Debian repo setup (`repo.mongodb.org/apt/debian ${VERSION_CODENAME}/mongodb-org/${MONGODB_SERIES} main`, `arch=amd64,arm64`, signed by the `server-${MONGODB_SERIES}.asc` key).
- Keep the per-arch tools `.deb` download (`debian12-x86_64` on amd64, `ubuntu2204-arm64` on arm64), now at `${MONGODB_TOOLS_VERSION}`.
- Install `mongodb-mongosh=${MONGOSH_VERSION}` instead of the unpinned `mongodb-mongosh`, together with `/tmp/mongodb-database-tools.deb`.
- Keep the comment that explains the arm64 workaround, and keep `USER node` at the end.

## Files to Change
- `node_mongo/0.3.0/Dockerfile` — new base, series, ARGs and pinned installs
