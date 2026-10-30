# Update the image READMEs
Rewrite both READMEs following `docs/agents/image-readme.md` and the structure of `circleci_node/0.2.2/README.md` / `node/0.2.2/README.md`:

- **About:** Node.js 22, built on `darthjee/circleci_node:0.2.2` (`cimg/node`) or `darthjee/node:0.2.2` (`node:22`). Remove the legacy/EOL note.
- **Pre-cached packages:** replace the old `npm -g install` list with the base image's pre-cached yarn package list. Copy it from the base README, or reference the base README.
- **Tools:** `mongosh` (MongoDB Shell) and MongoDB Database Tools (`mongodump`, `mongorestore`, `mongoimport`, `mongoexport`, ...). Drop `mongodb-clients` and the `mongo` shell mention.
- **User and working directory:** `circleci_node_mongo` runs as `circleci` in `/home/circleci/project`. `node_mongo` runs as `node` in `/home/node/app`.
- **Cross-links:** each README links to its counterpart (`darthjee/node_mongo` ↔ `darthjee/circleci_node_mongo`).
- **How to use:** switch examples from `npm install` / `npm test` to `yarn install` / `yarn test`, matching the base READMEs.

## Files to Change
- `circleci_node_mongo/0.2.2/README.md` — rewritten for the new base and tools
- `node_mongo/0.2.2/README.md` — rewritten for the new base and tools
