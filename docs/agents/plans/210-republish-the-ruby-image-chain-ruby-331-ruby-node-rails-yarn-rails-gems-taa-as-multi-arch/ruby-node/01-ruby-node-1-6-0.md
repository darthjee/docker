# ruby_node 1.6.0
Run `bin/script.sh init ruby_node 1.6.0`. Check that `FROM` now points to `darthjee/ruby_331:1.2.0`, `darthjee/circleci_ruby_331:1.2.0` and `darthjee/production_ruby_331:1.2.0`. Update the READMEs to the new version. Build and test all three variants, then check arm64 (NodeSource Node 22 install on arm64).

## Files to Change
- `ruby_node/1.6.0/**`, `circleci_ruby_node/1.6.0/**`, `production_ruby_node/1.6.0/**` — new versions created by `init`
- `version` — `ruby_node`, `circleci_ruby_node`, `production_ruby_node` → `1.6.0`
