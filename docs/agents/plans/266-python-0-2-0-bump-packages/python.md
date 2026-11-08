# Python Plan: python 0.2.0: bump packages

Main plan: [plan.md](plan.md)

## Overview
Add a new `0.2.0` version for `python` and `circleci_python`, created with `bin/script.sh init`. Both pin the base to Python `3.12.16` and stay on bookworm. Both install the same pinned `pipenv` through a `PIPENV_VERSION` ARG. The `0.1.0` folders, `python_37` and the `django` images are not touched.

## Context
- `python/0.1.0/Dockerfile`: `FROM python:3.12-slim-bookworm`, creates the `app` user (uid 1000) and `/home/app/app`, runs an unpinned `pip install --no-cache-dir pipenv`, and ends with `USER app`.
- `circleci_python/0.1.0/Dockerfile`: `FROM cimg/python:3.12`, creates `/home/circleci/project` owned by `circleci`, installs nothing, and ends with `USER circleci`. Its README says pipenv is "provided by the `cimg/python` base".
- Neither image has a `scripts` build stage, a `home/` folder or a `test/` folder, so the epic's "move to `darthjee/scripts:0.15.0`" rule does not apply.
- CI jobs `release-python` and `release-circleci_python` already exist in `.circleci/config.yml` and have no `requires`; nothing changes there.
- Latest at planning time (2026-11-08): Python `3.12.16` (`python:3.12.16-slim-bookworm`, `cimg/python:3.12.16`) and pipenv `2026.10.6`.

## Implementation Steps

### Step 1 — Create 0.2.0 and update the Dockerfiles
1. Run `bin/script.sh init python 0.2.0` and `bin/script.sh init circleci_python 0.2.0`. Set `python=0.2.0` and `circleci_python=0.2.0` in `version`.
2. `python/0.2.0/Dockerfile`:
   ```dockerfile
   FROM python:3.12.16-slim-bookworm

   ARG PIPENV_VERSION=2026.10.6

   RUN useradd -u 1000 app; \
       mkdir -p /home/app/app; \
       chown app:app -R /home/app

   WORKDIR /home/app/app

   RUN pip install --no-cache-dir pipenv==${PIPENV_VERSION}
   USER app
   ```
3. `circleci_python/0.2.0/Dockerfile`:
   ```dockerfile
   FROM cimg/python:3.12.16

   ARG PIPENV_VERSION=2026.10.6

   USER root

   RUN mkdir -p /home/circleci/project; \
       chown circleci:circleci -R /home/circleci/project

   USER circleci
   RUN pip install --no-cache-dir pipenv==${PIPENV_VERSION}
   WORKDIR /home/circleci/project
   ```
   Install as `circleci`: cimg/python's Python is managed by pyenv under the circleci user. Make sure the new pipenv is first on PATH and overrides any bundled one (`pipenv --version` must report the pinned version).
4. Before committing, re-check the latest 3.12.x tag and pipenv release. If newer versions exist, use them, keeping both images identical.

### Step 2 — READMEs, build and verify
1. Update `python/0.2.0/README.md` and `circleci_python/0.2.0/README.md` per `docs/agents/image-readme.md`:
   - Name the pinned bases (`python:3.12.16-slim-bookworm`, `cimg/python:3.12.16`).
   - In both Tools lists, say `pipenv` is pinned (`pipenv` `2026.10.6`, installed with `pip`). Drop circleci_python's "provided by the `cimg/python` base" wording.
2. Build each image on both architectures with `bin/image.sh build <image> amd64` and `bin/image.sh build <image> arm64`.
3. In both images, check that `python --version` reports `3.12.16` and `pipenv --version` reports the pinned version.
4. Run `bin/script.sh test python` and `bin/script.sh test circleci_python`. With no `test/` folder, both print "no tests for <image>"; that is expected.

## Files to Change
- `version` — bump `python` and `circleci_python` to `0.2.0`.
- `python/0.2.0/Dockerfile`, `python/0.2.0/README.md` — new version (via init).
- `circleci_python/0.2.0/Dockerfile`, `circleci_python/0.2.0/README.md` — new version (via init).

## CI Checks
- `python`: `bin/script.sh test python` (CI job: `release-python`)
- `circleci_python`: `bin/script.sh test circleci_python` (CI job: `release-circleci_python`)

## Notes
- The dependency on #257 (scripts 0.15.0) is nominal only: neither image uses the scripts stage, so this can be implemented right away.
- Do not edit the `0.1.0` folders in place.
- The `django` images build on upstream `python`/`cimg/python`, not `darthjee/python`, so they are out of scope here.
