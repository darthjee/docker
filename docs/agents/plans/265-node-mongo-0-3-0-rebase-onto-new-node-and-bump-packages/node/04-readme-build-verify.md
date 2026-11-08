# READMEs, build and verify
Update both READMEs, then build and check both images on both architectures.

READMEs (follow `docs/agents/image-readme.md`):
- `node_mongo/0.3.0/README.md`:
  - The upstream base is now the pinned `node:22.23.4` (Node.js 22). Don't name a `darthjee/` parent tag.
  - Keep `## What is added` (mongosh and the database tools).
  - Keep the pre-cached package list in sync with `node/0.3.0/README.md` from #264.
- `circleci_node_mongo/0.3.0/README.md`: the same changes, for `circleci_node` / `cimg/node:22.23.4`.

Build and verify:
```bash
bin/image.sh build node_mongo amd64
bin/image.sh build node_mongo arm64
bin/image.sh build circleci_node_mongo amd64
bin/image.sh build circleci_node_mongo arm64
bin/script.sh test node_mongo
bin/script.sh test circleci_node_mongo
```
In each built image (both archs), check that these succeed and show the pinned versions:
- `mongosh --version` (2.14.1)
- `mongodump --version` (100.20.1)

## Files to Change
- `node_mongo/0.3.0/README.md` — base/version wording and package list
- `circleci_node_mongo/0.3.0/README.md` — same
