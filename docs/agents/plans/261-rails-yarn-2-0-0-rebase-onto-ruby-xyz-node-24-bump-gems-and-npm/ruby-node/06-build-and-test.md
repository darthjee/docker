# Build and test on both arches
If `ruby_node:2.0.0` (and counterparts) are not yet on Docker Hub, build them locally first with `bin/script.sh build <ruby_node image>` (and `PLATFORM=linux/arm64 ...`).

For each of `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn`:

- `bin/script.sh build <image>` then `bin/script.sh test <image>` (amd64, default `PLATFORM`).
- `PLATFORM=linux/arm64 bin/script.sh build <image>` then `PLATFORM=linux/arm64 bin/script.sh test <image>`.
- `docker buildx build --platform linux/amd64,linux/arm64 -f <image>/2.0.0/Dockerfile <image>/2.0.0/` without `--push` (needs the parents on Docker Hub; if they are not published yet, report that instead of failing the step).
- Spot-check in the dev image: `ruby -v` (3.4.12), `node -v` (v24.x), `yarn -v` (1.22.22), `which ncat telnet`.

Existing subtests (`bundler.sh`, `node.sh`, circleci `user.sh` / `yarn_cache.sh`) must pass on both arches.

## Files to Change
- None (verification only).
