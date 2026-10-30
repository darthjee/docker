# Plan: Rebuild taap images as 1.5.0 on taa 1.5.0 and scripts 0.10.0

Issue: [202-rebuild-taap-images-as-1-5-0-on-taa-1-5-0-and-scripts-0-10-0.md](../../issues/202-rebuild-taap-images-as-1-5-0-on-taa-1-5-0-and-scripts-0-10-0.md)

## Overview
Create 1.5.0 of the three `taap` variants with `bin/script.sh init`, then rewrite their `home/`, `Dockerfile`, `test/` and `README.md` so they mirror `taa` 1.5.0, plus `danica` 3.0.0, the `gnuplot` gem and the apt `gnuplot` binary. This closes #197, #199 and #200.

## Context
- The 1.4.2 images can't be built: `darthjee/scripts:0.4.3` is gone from Docker Hub. They also never shipped `danica`/`gnuplot`, because their final stage copies from paths the builder doesn't write to.
- `taa` 1.5.0 (`taa/1.5.0`, `circleci_taa/1.5.0`, `production_taa/1.5.0`) is the reference for builder and final-stage layout.
- `danica` must be **3.0.0**. Version 2.7.7 needs `activesupport ~> 5.2` and `darthjee-core_ext ~> 2.x`, which conflicts with `taa` 1.5.0 (Rails 7.2, `core_ext` 3.1.0).
- #205 is merged: `bin/script.sh build` fails fast, and `bin/script.sh test` really runs `/home/<test>/test.sh` and returns its exit code. The 1.4.2 `test/test.sh` is already the canonical "fail if any subtest fails" runner, so `init` copies it as is.
- The `taa` chain is amd64-only on Docker Hub, so an arm64 build is out of scope (#210). Verify on amd64 only.
- Keep the 1.4.2 folders. Archiving them comes later.

## Steps

- [01 — Create the 1.5.0 version folders](ruby-node/01-init-version.md)
- [02 — Rewrite home/ contents](ruby-node/02-home-contents.md)
- [03 — Rewrite the Dockerfiles](ruby-node/03-dockerfiles.md)
- [04 — Rewrite the tests](ruby-node/04-tests.md)
- [05 — Update the READMEs](ruby-node/05-readmes.md)
- [06 — Build, test and record evidence](ruby-node/06-verify.md)

## CI Checks
CircleCI only runs release jobs on tags, so a PR runs no CI job for these images. Run locally:
- `bin/script.sh build taap` (builds `taap`, `circleci_taap` and `production_taap`, pulling or building their bases)
- `bin/script.sh test taap` (runs each image's `test/test.sh` and fails if any subtest fails)

## Notes
- **Backward compatibility (state it in the PR description, not in the READMEs):** `newrelic_rpm` is removed (it follows `taa`, so it's not re-added to `production_taap`). Major bumps: `rack` 2.2 → 3.1, `puma` 6 → 7, `darthjee-core_ext` 2 → 3.1, `shoulda-matchers` 5 → 7. Node may move to 22. Ruby stays 3.3.1. `danica` 3.0.0 and the `gnuplot` gem are added.
- The PR body must contain `Closes #197`, `Closes #199` and `Closes #200` (as well as `Closes #202`).
- `circleci_taa/1.5.0/test/subtests/bundler.sh` checks `/home/circleci/app/Gemfile`, which looks wrong. Don't copy that path. It's out of scope here.
- Leave the 1.4.2 folders and the CircleCI config unchanged.
