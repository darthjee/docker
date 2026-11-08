# Build and test on both arches
For each of `ruby_node`, `circleci_ruby_node`, `production_ruby_node`:

- `bin/script.sh build <image>` then `bin/script.sh test <image>` (amd64, default `PLATFORM`).
- `PLATFORM=linux/arm64 bin/script.sh build <image>` then `PLATFORM=linux/arm64 bin/script.sh test <image>`.
- `docker buildx build --platform linux/amd64,linux/arm64 -f <image>/2.0.0/Dockerfile <image>/2.0.0/` without `--push`.

All subtests (`bundler.sh`, `node.sh`, `tools.sh`) must pass on both arches.

## Files to Change
- None (verification only).
