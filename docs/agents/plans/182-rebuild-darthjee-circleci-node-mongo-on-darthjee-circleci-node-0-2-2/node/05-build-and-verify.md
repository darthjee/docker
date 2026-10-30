# Build and verify both architectures
For each image (`node_mongo`, `circleci_node_mongo`):

1. Run `bin/script.sh pre_build <image>` and `bin/script.sh build <image>`. Both must exit 0.
2. Smoke test the image: `docker run --rm darthjee/<image>:0.2.2 sh -c 'whoami; node --version; mongosh --version; mongodump --version'`. Expect `circleci` / `node`, Node v22, and working MongoDB tools.
3. Verify arm64 builds as well. Use the arch-specific local build supported by `bin/image.sh build <image> arm64` (QEMU/binfmt), or `docker buildx build --platform linux/arm64`. Re-run the version smoke test under `--platform linux/arm64` if emulation is available.

Report the outputs in the PR. If arm64 can't be verified locally, say so explicitly.

## Files to Change
- none (verification only)
