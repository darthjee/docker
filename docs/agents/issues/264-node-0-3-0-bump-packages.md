# Issue: node 0.3.0: bump packages

## Description
`node` and `circleci_node` (both `0.2.4`) are built on `node:22` / `cimg/node:22.14.0` and use `darthjee/scripts:0.11.0`. Part of epic #256: create `0.3.0` of both images, keep Node 22 (still LTS) and bump only packages.

## Problem
- The npm dependencies in `home/package.json` are stale and mix exact pins, ranges (`^`/`~`) and `latest` (`express-generator`), so builds are not reproducible.
- The `scripts` stage still points to `0.11.0`.
- `node` uses the floating `node:22` tag while `circleci_node` pins an old `cimg/node:22.14.0`, so dev and CI can run different Node patches.

## Expected Behavior
- `node/0.3.0` and `circleci_node/0.3.0` exist (created with `bin/script.sh init`), and the `version` file points to them.
- Both use the same exact Node 22.x patch.
- Every `package.json` dependency is an exact version, identical in both images.
- Both images build on `linux/amd64` and `linux/arm64`, and `bin/script.sh test` passes for both.
- Each new version has an updated `README.md` (per `docs/agents/image-readme.md`).

## Solution
- Create `0.3.0` for `node` and `circleci_node` with `bin/script.sh init`.
- Move the `scripts` stage to `darthjee/scripts:0.15.0` (use uppercase `AS`, as in the 2.0.0 images).
- Pin both base images to the same latest 22.x patch: `node:22.x.y` and `cimg/node:22.x.y`, checking that the tag exists for both and for both architectures.
- Bump the `package.json` dependencies to the latest release on their **current major lines**: eslint stays on 8, express on 4, nyc on 15 and so on, with no major bumps. Pin every entry, including `express-generator`, to an exact version.
- Keep `home/` identical between `node` and `circleci_node`.
- Update the `version` file and the READMEs, and run the tests.

Depends on #257 (scripts 0.15.0, merged). Part of epic #256.

## Benefits
- Up-to-date, reproducible tooling for Node projects and CI, with no breaking changes for consumers' lint configs or apps.
- Dev and CI share one Node patch.
- A pinned base for `node_mongo` 0.3.0 (#265), which can share the exact versions (see #274).
