# Rebuild node_mongo Dockerfile
Rewrite `node_mongo/0.2.2/Dockerfile` in the same way as step 02, but:

- `FROM darthjee/node:0.2.2` (Debian, from `node:22`). Use MongoDB's Debian repo for the image's codename (`https://repo.mongodb.org/apt/debian <codename>/mongodb-org/<series> main`) if it provides the packages. Otherwise use the Ubuntu repo or per-arch `.deb` downloads (see the Notes in `node.md`).
- arm64 must work. If the Debian repo is amd64-only, the install must branch on `dpkg --print-architecture`, or use a source that serves both architectures.
- End with `USER node`.

## Files to Change
- `node_mongo/0.2.2/Dockerfile` — new base, MongoDB tools install that works on amd64 and arm64, `USER node`
