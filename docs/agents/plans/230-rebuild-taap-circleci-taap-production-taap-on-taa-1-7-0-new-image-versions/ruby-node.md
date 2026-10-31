# Ruby-Node Plan: Rebuild taap / circleci_taap / production_taap on taa 1.7.0 (new image versions)

Main plan: [plan.md](plan.md)

## Overview
Create a new minor version 1.7.0 for the three `taap` images, copied from 1.6.0 and built on the `taa` 1.7.0 bases. `taap` has no `package.json` of its own, so it picks up the JS upgrades from `taa` 1.7.0.

## Context
- `taap` / `circleci_taap` / `production_taap` 1.6.0 were added by #221 and are already on Docker Hub. They are built on `*taa:1.6.1`, which still has `js-cookie` 2.2.1 and `angular` 1.4.8.
- `taa` / `circleci_taa` / `production_taa` 1.7.0 were merged in #229 and the `version` file already says `*taa=1.7.0`.
- `bin/script.sh init taap 1.7.0` handles all three variants (`""`, `circleci_`, `production_`). It copies `<image>/1.6.0` to `<image>/1.7.0`, sets `<image>=1.7.0` in `version`, and rewrites every `darthjee/<img>:<ver>` `FROM` to the version in `version`. That gives `taa:1.7.0` and `scripts:0.11.0`.
- Checked during planning: each `*taap/1.6.0/home/Gemfile.lock` differs from the matching `*taa/1.7.0/home/Gemfile.lock` only by `danica` (3.0.0) and `gnuplot` (2.6.2). The copied lock files are already a pure delta.

## Steps

- [01 — Create the 1.7.0 version folders](ruby-node/01-create-version-folders.md)
- [02 — Update the READMEs](ruby-node/02-update-readmes.md)
- [03 — Build and test](ruby-node/03-build-and-test.md)

## CI Checks
- `taap`, `circleci_taap`, `production_taap`: `bin/script.sh test taap circleci_taap production_taap` (CI jobs: `release-taap`, `release-circleci_taap`, `release-production_taap`, which require `release-*taa` and `release-scripts`)

## Notes
- The `taap` image builds need `darthjee/*taa:1.7.0` on Docker Hub, or built locally first. When planning, Docker Hub still only listed `taa` up to 1.6.1. If the pull fails, build the `taa` 1.7.0 images locally before testing.
- Leave the root `README.md` image list (still on 1.4.2 everywhere) alone. It is stale for every image and sibling issues haven't updated it either.
- After merge, close Dependabot PRs #125 and #138 as superseded. The person merging does this; it is not a code change.
