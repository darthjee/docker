# Issue: Make bin/script.sh build and test exit non-zero on failure

## Description
`bin/script.sh build <images>` exits 0 even when a base fetch or image build fails, and `bin/script.sh test <images>` passes for most images without actually running their tests. Noticed during #169 / PR #201 (the ruby-node check printed build errors but reported success). Split out of #202.

## Problem
### Build (`bin/build.sh`, `bin/image.sh build`)
- `fetch_bases` runs `docker pull $BASE || $0 build $BUILDABLE`. When the pull fails, the fallback builds the base at the version currently in `version`, not at the pinned tag in the `FROM`. The pinned tag still doesn't exist, the `FROM` fails, and the script carries on.
- `build` / `build_images` loop over images without checking each `build_image` / `bin/image.sh build` result; the exit status is whatever the last command returned.
- `bin/image.sh build` doesn't check `docker build` either, and still runs `docker tag` after a failed build.

### Test (`bin/image.sh test`, per-image `test/test.sh`)
Partly done already: `bin/test.sh` now propagates failures, and images with their own `test/Dockerfile` (only `scripts/0.11.0`) run `/home/test/test.sh` and return its status. What remains:
- The default path (`Dockerfile.test`) still runs `docker-compose run test pwd`, overriding `command: /home/test/test.sh`, so tests never run for any other image, and the build step's status isn't checked.
- 20 current-version `test/test.sh` files (ruby_331, rails_gems, rails_bower, rails_yarn, ruby_node, taa, taap and their circleci_/production_ variants) use `/bin/bash $TEST || exit 0`, so a failing subtest exits 0 and stops the remaining subtests.

## Expected Behavior
- Any failed base fetch or image build stops `bin/script.sh build ...` right there and exits non-zero (fail fast: circleci_/production_ variants build on the base, so continuing only adds noise).
- When the pull fails and the fallback build doesn't produce the pinned tag, the script says so clearly and fails.
- `bin/image.sh test` runs `/home/test/test.sh` for every image (no `pwd` override) and returns its exit code; a failed test-image build also fails. Images with no `test/` folder (node, node_mongo, python_37, django and their variants) are skipped with a "no tests for <image>" message and return 0. `bin/script.sh test <images>` exits non-zero when any image's tests fail.
- Every current-version `test/test.sh` runs all subtests and exits non-zero if any fails (the `scripts/0.11.0/test/test.sh` pattern).
- Editing `test/` in a current version folder doesn't trigger a re-push of that version on the next release.
- Image tests that turn out to be already broken once the runner works are not fixed here; each gets a follow-up issue.

## Solution
- `bin/build.sh`: `fetch_bases`, `build_image`, `build_images` and `build` return non-zero on the first failure (`|| return 1`), and `build` stops looping. After a fallback build in `fetch_bases`, verify the pinned `$BASE` exists locally (`docker image inspect`) and fail with a clear message if not.
- `bin/image.sh build`: stop if `docker build` fails.
- `bin/image.sh image_test`: skip with a message when `$image/$version/test/` doesn't exist; otherwise collapse to a single path — `TEST_DOCKERFILE` defaults to `Dockerfile.test`, `build test || return 1`, then `run --rm test` and return its status.
- `bin/image.sh push`: also pass `:(exclude)$image/$version/test/` to `skip_if_unchanged` (test files aren't part of the image).
- Replace the 20 `test/test.sh` copies with the `scripts/0.11.0` pattern.
- Run `bin/script.sh test` on the affected images; open a follow-up issue (via spawn, cross-referenced to #205) for any image whose tests were already broken.
- Update `docs/agents/architecture.md` (testing section) to match.

## Benefits
Build and test failures become visible locally and to agents running the scripts, instead of being reported as success.
