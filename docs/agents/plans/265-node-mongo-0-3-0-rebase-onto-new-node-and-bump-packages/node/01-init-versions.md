# Init new versions
Create the new version folders from the current ones and register them. Never edit the `0.2.3` folders in place.

```bash
bin/script.sh init node_mongo 0.3.0
bin/script.sh init circleci_node_mongo 0.3.0
```

Then make sure the `version` file has `node_mongo=0.3.0` and `circleci_node_mongo=0.3.0`. Fix it if `init` did not update it.

## Files to Change
- `node_mongo/0.3.0/` — new folder, copied from `0.2.3`
- `circleci_node_mongo/0.3.0/` — new folder, copied from `0.2.3`
- `version` — `node_mongo=0.3.0`, `circleci_node_mongo=0.3.0`
