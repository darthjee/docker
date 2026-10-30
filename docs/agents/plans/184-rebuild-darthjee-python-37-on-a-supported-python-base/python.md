# Python Plan: Rebuild darthjee/python_37 on a supported Python base

Issue: [184-rebuild-darthjee-python-37-on-a-supported-python-base.md](../../issues/184-rebuild-darthjee-python-37-on-a-supported-python-base.md)

## Overview
Replace the end-of-life `python_37` / `circleci_python_37` images (Python 3.7.2, Debian stretch / legacy `circleci/python`) with new, version-agnostic `python` and `circleci_python` families on Python 3.12. The old images stay in the repo as deprecated.

## Context
- `python_37/0.2.2/Dockerfile`: `FROM python:3.7.2`, creates user `app` (uid 1000), `WORKDIR /home/app/app`, `pip install pipenv`, `USER app`.
- `circleci_python_37/0.2.2/Dockerfile`: `FROM circleci/python:3.7.2`, `WORKDIR /home/circleci/project`, `pip install pipenv`, `USER circleci`.
- `django/0.1.0` already uses `python:3.12-slim-bookworm`; `circleci_django/0.1.0` uses `cimg/python:3.12`. Reuse these bases.
- `bin/image.sh push` already builds `linux/amd64,linux/arm64` via buildx, so multi-arch needs no extra work.
- No image in the repo builds on top of `python_37`, and there is no `production_python_37`.
- Decisions from the issue: new names `python` / `circleci_python`, keep `pipenv`, keep `python_37` as deprecated, rebuild the CircleCI counterpart in this issue, `python` agent owns the new folders.

## Steps

- [01 — Create python/0.1.0](python/01-create-python-image.md)
- [02 — Create circleci_python/0.1.0](python/02-create-circleci-python-image.md)
- [03 — Deprecate python_37 and circleci_python_37](python/03-deprecate-python-37.md)
- [04 — Wire the new images into root files and docs](python/04-root-wiring-and-docs.md)

## CI Checks
- `python`, `circleci_python`: `bin/script.sh pre_build <image> && bin/script.sh build <image> && bin/script.sh test <image>` (CI jobs: `release-python`, `release-circleci_python`, tag-triggered)
- `.claude/scripts/check_python.sh` (after step 04 adds the new images to its loop)
- README-only changes (step 03) need no build/test, per `docs/agents/image-readme.md`.

## Notes
- Step 04 touches root-level files (`version`, `.circleci/config.yml`, `README.md`, `docs/`, `.claude/`). These are outside the `python` agent's current "image directories only" rule, so the architect should do step 04, or explicitly allow the `python` agent to do it for this issue.
- `python:3.12-slim-bookworm` has no compiler. Projects whose pipenv dependencies need C extensions would need `build-essential`. This plan keeps the image minimal, matching `python_37` (which had compilers only because the full `python:3.7.2` base included them). Note this in the README.
- `cimg/python:3.12` may already ship `pipenv`. If it does, the Dockerfile only needs the working-directory setup; check with `docker run --rm cimg/python:3.12 pipenv --version`.
- The new images are new families, so their folders are created directly rather than with `bin/script.sh init python_37`. The Dockerfiles in `python_37/0.2.2` and `circleci_python_37/0.2.2` stay unchanged.
