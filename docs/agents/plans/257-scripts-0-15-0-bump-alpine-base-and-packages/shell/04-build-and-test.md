# Build and test
Build and test the new image: `bin/script.sh build scripts` and `bin/script.sh test scripts`. All `test/subtests` must pass. Verify the multi-arch build (`docker buildx build --platform linux/amd64,linux/arm64 scripts/0.15.0`), and check that `docker run --rm darthjee/scripts:0.15.0 bash -c 'curl --version && jq --version'` works.

## Files to Change
- None (verification only).
