# Architect Plan: scripts 0.11.0: harden deploy_frontend.sh and add staging, run and host-key support

Main plan: [plan.md](plan.md)

## Shared contracts

- Provide: when `<image>/<version>/test/Dockerfile` exists, `bin/image.sh test <image>` builds
  with it (context: repo root, same build args as today) and runs the image's default command
  (`/home/test/test.sh`), returning its exit status.
- Rely on: the shell agent ships `scripts/0.11.0/test/Dockerfile` and a `test.sh` that exits
  non-zero on failure.
- Keep: images without that file use `Dockerfile.test` and run `pwd` exactly as today.

## Implementation Steps

### Step 1 — Make the test Dockerfile configurable in docker-compose

In `docker-compose.yml`, change the `test` service's `dockerfile: Dockerfile.test` to
`dockerfile: ${TEST_DOCKERFILE:-Dockerfile.test}`, so the default stays the same.

### Step 2 — Use a per-version test Dockerfile in `bin/image.sh test`

In `image_test` (`bin/image.sh`), compute `test_dockerfile="$image/$version/test/Dockerfile"`.
When it exists, pass `TEST_DOCKERFILE="$test_dockerfile"` to `docker-compose build test`, and run
`docker-compose run --rm test` with no command override (so `/home/test/test.sh` runs), returning
its exit status. Otherwise keep today's `Dockerfile.test` + `run test pwd` behavior unchanged.
Also check `bin/test.sh` propagates the failure (today `test_image` ignores return values; make
`test_images`/`testy` return non-zero when an image's test fails).

## Files to Change

- `docker-compose.yml` — `TEST_DOCKERFILE` with `Dockerfile.test` default.
- `bin/image.sh` — per-version test Dockerfile detection in `image_test`.
- `bin/test.sh` — propagate test failures to the exit status.

## Notes

- Changing every image to run `test.sh` instead of `pwd` is out of scope: older images'
  `test.sh` files use `|| exit 0` and may not pass if really run.
- Verify with `bin/script.sh test scripts` (after the shell agent's work) and that
  `bin/script.sh test taa` behaves as before.
- CI (`.circleci/config.yml`) runs no tests today; adding a test job is out of scope.
