# Replace ruby_node bundler subtest with a smoke test
ruby_node, circleci_ruby_node and production_ruby_node 1.5.0 ship no Gemfile, so `bundle check --gemfile=...` always fails with `Gemfile not found`. Replace it with a smoke test that exits non-zero if any of the tools are missing:

```bash
#!/bin/bash

ruby --version && gem --version && bundle --version
```

Keep the file name `bundler.sh` so `test.sh`'s `subtests/*.sh` loop picks it up. No version bump and no change to `version`.

## Files to Change
- `ruby_node/1.5.0/test/subtests/bundler.sh`: replace `bundle check` with the smoke test.
- `circleci_ruby_node/1.5.0/test/subtests/bundler.sh`: same.
- `production_ruby_node/1.5.0/test/subtests/bundler.sh`: same.
