# Init the 0.2.2 version
Run `bin/script.sh init node_mongo 0.2.2` from the repo root. This creates `node_mongo/0.2.2/` and `circleci_node_mongo/0.2.2/` as copies of `0.0.6`, sets `node_mongo=0.2.2` and `circleci_node_mongo=0.2.2` in `version`, and rewrites the `FROM` lines to `darthjee/node:0.2.2` and `darthjee/circleci_node:0.2.2`. Check the diff and confirm both `FROM` lines and both `version` entries are correct.

## Files to Change
- `version` — `node_mongo` and `circleci_node_mongo` bumped to `0.2.2` (by init)
- `node_mongo/0.2.2/Dockerfile`, `node_mongo/0.2.2/README.md` — created by init
- `circleci_node_mongo/0.2.2/Dockerfile`, `circleci_node_mongo/0.2.2/README.md` — created by init
