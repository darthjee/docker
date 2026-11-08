# Python Plan: django 0.2.0: bump packages

Main plan: [plan.md](plan.md)

## Overview
Create `0.2.0` versions of `django`, `circleci_django` and `production_django`. They:
- pin their bases to Python 3.12.16, matching `python`/`circleci_python` 0.2.0 from #266
- take the poetry builder from `darthjee/scripts:0.15.0`
- pin poetry 2.5.1 in all three images
- stay on the Django 5.2 LTS line (5.2.19), with the other `pyproject.toml` dependencies bumped

## Context
- In `0.1.0`:
  - `django` and `production_django` are built on `python:3.12-slim-bookworm` and install `poetry==2.2.1`.
  - `circleci_django` is built on `cimg/python:3.12`, which ships poetry 2.5.1 without a pin.
  - All three use `FROM darthjee/scripts:0.9.0 as scripts` and `poetry_builder.sh`:
    - `django`: no args
    - `circleci_django`: `-v`, with `APP_DIR=/home/circleci/project`
    - `production_django`: `--only main`
- All three share an identical `home/pyproject.toml`, and there is no `poetry.lock`.
- There are no `test/` folders, so `bin/script.sh test` prints "no tests for <image>".
- CI jobs: `release-django`, `release-circleci_django`, `release-production_django`.

## Implementation Steps

### Step 1 — Create the 0.2.0 versions and update the Dockerfiles
For each of `django`, `circleci_django` and `production_django`, run `bin/script.sh init <image> 0.2.0` and point the `version` file entries at `0.2.0`. Then make these changes in each new `Dockerfile`, keeping the 0.1.0 structure (base / builder / final stages, apt packages, builder args):

- `FROM darthjee/scripts:0.15.0 AS scripts`.
- Base image:
  - `django` and `production_django`: `FROM python:3.12.16-slim-bookworm AS base`.
  - `circleci_django`: `FROM cimg/python:3.12.16 AS base`.
- Add `ARG POETRY_VERSION=2.5.1` to the base stage.
- Install poetry:
  - `django` and `production_django`: `RUN pip install --no-cache-dir poetry==${POETRY_VERSION}`.
  - `circleci_django`: run the same install as the `circleci` user, after the root apt step, so poetry lands in the user's pyenv like #266's pipenv install.
- Tidy legacy syntax:
  - `as` → `AS`
  - `ENV HOME_DIR /home/app` → `ENV HOME_DIR=/home/app`, and the same for the other `ENV` lines
  - `chown app.app` → `chown app:app`

Before pinning, re-check the latest 3.12.x tags on Docker Hub (python and cimg/python) and the latest poetry release. Use newer versions if they exist, and keep the three images in sync.

### Step 2 — Bump pyproject dependencies, update READMEs, build and verify
Update `home/pyproject.toml` identically in all three new versions. Keep the existing style: exact pins stay exact, caret pins stay caret. Re-check PyPI when implementing. As of 2026-11-08:

- Main:
  - `django = "5.2.19"`. Stay on 5.2 LTS; do **not** move to 6.x.
  - `django-admin = "2.0.2"`
  - `mysqlclient = "2.3.0"`
  - `gunicorn = "26.2.0"`
  - `jinja2 = "^3.1.6"`
- Dev:
  - `pytest = "9.2.0"`
  - `pytest-django = "4.14.0"`
  - `ruff = "0.17.4"`
  - `radon = "^6.0.1"`
  - `xenon = "^0.9.3"`
  - `lizard = "^1.25.1"`

Update each new `README.md` per `docs/agents/image-readme.md`: Python 3.12.16, poetry 2.5.1, Django 5.2.19, scripts 0.15.0, and the circleci_django poetry note.

Build each image on both arches with `bin/image.sh build <image> amd64` and `bin/image.sh build <image> arm64`. `mysqlclient` must compile against `default-libmysqlclient-dev`.

Smoke-check each built image:
- `python --version` shows 3.12.16.
- `poetry --version` shows 2.5.1.
- `python -c "import django; print(django.get_version())"` shows 5.2.19, using the cached artifacts / installed env as each image provides.

Finally, run `bin/script.sh test` for each image.

## Files to Change
- `version`: `django`, `circleci_django` and `production_django` set to `0.2.0`
- `django/0.2.0/Dockerfile`, `django/0.2.0/home/pyproject.toml`, `django/0.2.0/README.md`: new
- `circleci_django/0.2.0/Dockerfile`, `circleci_django/0.2.0/home/pyproject.toml`, `circleci_django/0.2.0/README.md`: new
- `production_django/0.2.0/Dockerfile`, `production_django/0.2.0/home/pyproject.toml`, `production_django/0.2.0/README.md`: new

## CI Checks
- `django`, `circleci_django`, `production_django`: `bin/script.sh test <image>` and `bin/image.sh build <image> <arch>` (CI jobs: `release-django`, `release-circleci_django`, `release-production_django`)

## Notes
- Do not edit the `0.1.0` folders.
- Out of scope: rebasing onto `darthjee/python`, and Django 6.x.
- The #257 dependency (`scripts:0.15.0`) is already released.
- If a bumped dependency fails to resolve or build on either arch, step back to the newest working release and record why in the PR.
