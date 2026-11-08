# Create the 0.3.0 versions
Run `bin/script.sh init node 0.3.0` and `bin/script.sh init circleci_node 0.3.0`. Each copies the `0.2.4` folder to `0.3.0` and updates the `version` file. Never edit the `0.2.4` folders.

Check that `version` now has `node=0.3.0` and `circleci_node=0.3.0`, and that `node_mongo` / `circleci_node_mongo` are unchanged.

## Files to Change
- `node/0.3.0/` — new folder (copied from `0.2.4`).
- `circleci_node/0.3.0/` — new folder (copied from `0.2.4`).
- `version` — `node=0.3.0`, `circleci_node=0.3.0`.
