# Single test path in bin/image.sh test

Rewrite `image_test()`:

1. If `$image/$version/test/` doesn't exist, `echo "no tests for $image"` and `return 0`.
2. Set `test_dockerfile` to `$image/$version/test/Dockerfile` if it exists, otherwise `Dockerfile.test`.
3. Build: the existing `docker-compose build test` call with `TEST_DOCKERFILE="$test_dockerfile"` and `DOCKER_DEFAULT_PLATFORM="$PLATFORM"`, `|| return 1`.
4. Run: `docker-compose run --rm test` (no `pwd`), and `return $?`.

This removes the old second branch that ran `pwd`. `docker-compose.yml` already defaults `TEST_DOCKERFILE` to `Dockerfile.test` and sets `command: /home/test/test.sh`, so it needs no change.

## Files to Change
- `bin/image.sh` — `image_test()` collapsed to one path that runs the real tests, skips images without `test/`
