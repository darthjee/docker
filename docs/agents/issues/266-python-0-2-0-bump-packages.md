# Issue: python 0.2.0: bump packages

## Description
`python` (`0.1.0`) and its counterpart `circleci_python` (`0.1.0`) are Python 3.12 images built on `python:3.12-slim-bookworm` and `cimg/python:3.12`. As part of epic #256, both get a new `0.2.0` version that keeps Python 3.12 and bumps packages. `python_37` is deprecated and out of scope. The `django` images build on upstream `python`/`cimg/python` rather than `darthjee/python`, so they are not touched here.

## Problem
- Both base tags float (`3.12`), so a rebuild silently picks up a different patch release.
- `python` installs `pipenv` unpinned. `circleci_python` installs nothing and relies on whatever `cimg/python` happens to ship, so the counterparts can run different pipenv versions.

## Expected Behavior
- `python/0.2.0` and `circleci_python/0.2.0` exist, both created with `bin/script.sh init <image> 0.2.0`; the `0.1.0` folders stay untouched.
- Base images are pinned to Python `3.12.16`: `python:3.12.16-slim-bookworm` and `cimg/python:3.12.16`. Both stay on Debian bookworm, not trixie.
- `pipenv` is pinned to the same exact version (`2026.10.6`, the latest at refinement time; re-check when implementing) in both images.
- The `version` file and each new `README.md` (per `docs/agents/image-readme.md`) are updated.
- Both images build on `linux/amd64` and `linux/arm64`, and `bin/script.sh test` passes for each.

## Solution
1. Run `bin/script.sh init python 0.2.0` and `bin/script.sh init circleci_python 0.2.0`, then update `version`.
2. `python/0.2.0/Dockerfile`: `FROM python:3.12.16-slim-bookworm`, and add `ARG PIPENV_VERSION=2026.10.6` with `pip install --no-cache-dir pipenv==${PIPENV_VERSION}`.
3. `circleci_python/0.2.0/Dockerfile`: `FROM cimg/python:3.12.16`, and install `pipenv==${PIPENV_VERSION}` with the same ARG so the counterparts match.
4. Neither image has a `scripts` build stage, so the epic's "move to `darthjee/scripts:0.15.0`" rule does not apply. The dependency on #257 is nominal only.
5. Update both READMEs (pinned Python version, pinned pipenv in the Tools list for both), build each image for amd64 and arm64 with `bin/image.sh build`, and run the tests.

## Benefits
- Reproducible builds with an explicit Python patch release.
- Matching pipenv versions across the dev and CI counterparts.
- Picks up the latest Python 3.12 security fixes without a major-version jump.
