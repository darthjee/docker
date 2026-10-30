# Issue: Rebuild darthjee/python_37 on a supported Python base

## Description
`darthjee/python_37` (`python_37/0.2.2/Dockerfile`) is built on `python:3.7.2` (2019, Debian stretch), and its CircleCI counterpart `darthjee/circleci_python_37` is built on the legacy `circleci/python:3.7.2`. Both Python 3.7 (EOL June 2023) and Debian stretch are end-of-life. The images were last pushed to Docker Hub in 2019, amd64 only. No image in this repo builds on top of them.

Related: #160

## Problem
- Anyone using `darthjee/python_37` / `darthjee/circleci_python_37` gets an unsupported interpreter and OS with no security updates.
- The `_37` name pins a Python version, so moving it to a supported Python would make the name misleading.

## Expected Behavior
- A new `darthjee/python` development image, built on `python:3.12-slim-bookworm` (the same base as `django` 0.1.0), shipping `pipenv` as today, running as the non-root `app` user (uid 1000) with `WORKDIR /home/app/app`.
- A new `darthjee/circleci_python` CircleCI counterpart, built on `cimg/python:3.12` (the same base as `circleci_django`), shipping `pipenv`, running as the `circleci` user with `WORKDIR /home/circleci/project`.
- Both new images are published multi-arch (`linux/amd64` + `linux/arm64`). `bin/image.sh push` already does this, so nothing extra is needed.
- `python_37` and `circleci_python_37` are kept but marked deprecated: folders and CI release jobs stay, and their READMEs point to the new images.

## Solution
- **New image folders** `python/<version>/` and `circleci_python/<version>/` (starting version `0.1.0`), each with a `Dockerfile` and a `README.md` following `docs/agents/image-readme.md`. Since these are new families, create the folders directly; do not copy the version via `bin/script.sh init python_37` and do not modify `python_37/0.2.2` / `circleci_python_37/0.2.2` Dockerfiles.
- **Owning agent:** the `python` specialist owns both new top-level folders. Extend `.claude/agents/python.md` (scope list and description) and the architect roster table in `.claude/agents/architect.md` to include `python/` and `circleci_python/`.
- **Wiring:** add `python` and `circleci_python` to the root `version` file, add `release-python` / `release-circleci_python` jobs to `.circleci/config.yml`, add both to `.claude/scripts/check_python.sh`, list them in the root `README.md` image list, and update `docs/agents/folder-structure.md` and `docs/agents/image-readme.md` where relevant.
- **Deprecation:** update `python_37/0.2.2/README.md` and `circleci_python_37/0.2.2/README.md` to say the image is deprecated and point to `darthjee/python` / `darthjee/circleci_python`. Mark them as deprecated in the root `README.md` and docs as well.

## Benefits
- Python projects get a supported, multi-arch dev/CI base image with security updates.
- The image names no longer pin a Python version, so future Python bumps are just version folders.
- Existing `python_37` users are pointed to the replacement instead of being broken.
