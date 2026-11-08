# Issue: django 0.2.0: bump packages

## Description
`django` (`0.1.0`) and its `circleci_django` / `production_django` counterparts are built on the floating tags `python:3.12-slim-bookworm` / `cimg/python:3.12`. They copy their poetry builder from `darthjee/scripts:0.9.0`, pin poetry `2.2.1` (circleci_django uses whatever poetry cimg ships), and pin Django `5.2.5` along with older app and dev dependencies.

Part of epic #256. Depends on #257 (`scripts 0.15.0`), which is already merged and released.

## Problem
- The base tags float, so builds are not reproducible, and they don't match `python 0.2.0` (#266), which pins `3.12.16`.
- `scripts:0.9.0` is outdated and differs from the `0.15.0` used by the rest of the epic.
- Poetry, Django (5.2.5 → 5.2.19) and the other pyproject dependencies are behind, missing security and bug fixes.
- circleci_django's poetry version depends on the cimg base and can drift away from the other two images.

## Expected Behavior
- New version `0.2.0` for `django`, `circleci_django` and `production_django`, created with `bin/script.sh init <image> 0.2.0`. The `0.1.0` folders stay untouched.
- Bases are pinned to `python:3.12.16-slim-bookworm` (django, production_django) and `cimg/python:3.12.16` (circleci_django), matching #266.
- The `scripts` build stage uses `darthjee/scripts:0.15.0`.
- All three images pin poetry `2.5.1` through `ARG POETRY_VERSION`. circleci_django installs it explicitly instead of relying on cimg.
- Django stays on the 5.2 LTS line: `5.2.19`.
- The other `pyproject.toml` dependencies are bumped to their latest compatible releases (re-check when implementing). As of 2026-11-08 these are mysqlclient 2.3.0, gunicorn 26.2.0, jinja2 ^3.1.6, pytest 9.2.0, pytest-django 4.14.0, ruff 0.17.4, radon ^6.0.1, xenon ^0.9.3, lizard ^1.25.1. django-admin stays at 2.0.2. All three images share the same `pyproject.toml`.
- `version` and each new `README.md` are updated per `docs/agents/image-readme.md`.
- All three images build on `linux/amd64` and `linux/arm64`, and `bin/script.sh test` passes for each.

## Solution
- Run `bin/script.sh init` for each image at `0.2.0` and update `version`.
- In each Dockerfile:
  - Bump the `FROM` tags.
  - Switch `scripts` to `0.15.0`.
  - Add `ARG POETRY_VERSION=2.5.1` and run `pip install --no-cache-dir poetry==${POETRY_VERSION}`. In circleci_django, run the install as the `circleci` user.
  - Tidy legacy syntax while there: `as` → `AS`, `ENV KEY value` → `ENV KEY=value`, `chown app.app` → `app:app`.
- Update `home/pyproject.toml` identically in all three images, keeping the existing pinning style: exact pins stay exact, caret pins stay caret.
- Out of scope: rebasing the django images onto `darthjee/python`, and moving to Django 6.x.

## Benefits
- Reproducible builds whose Python version matches the `python` 0.2.0 images.
- Current, patched dependencies on the supported Django LTS line, with no app-breaking framework jump.
- The same poetry version in dev, CI and production images.
