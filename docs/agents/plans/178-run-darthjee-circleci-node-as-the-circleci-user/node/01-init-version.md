# Init circleci_node 0.2.3
Run `bin/script.sh init circleci_node` from the repo root. It copies `circleci_node/0.2.2` to `circleci_node/0.2.3`, sets `circleci_node=0.2.3` in `version`, and updates the `darthjee/*` `FROM` lines (e.g. `darthjee/scripts`) to the versions in `version`. `0.2.2` is never edited in place.

If `init` bumps `darthjee/scripts` (0.10.0 → 0.11.0), diff `scripts/0.10.0/home/builder/yarn_builder.sh` against `scripts/0.11.0/...`. If yarn_builder changed in a way that matters, keep it pinned to 0.10.0.

## Files to Change
- `version` — `circleci_node=0.2.3`
- `circleci_node/0.2.3/` — new folder (copy of 0.2.2)
