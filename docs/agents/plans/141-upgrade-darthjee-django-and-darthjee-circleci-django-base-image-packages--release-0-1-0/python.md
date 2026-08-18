# python Plan: Upgrade darthjee/django and darthjee/circleci_django base image packages (release 0.1.0)

Main plan: [plan.md](plan.md)

## Overview

`django/0.0.2` and `production_django/0.0.2` are built `FROM python:3.12-slim-bullseye` (Debian 11, now `oldoldstable`) with `poetry` installed unpinned; `circleci_django/0.0.2` is built `FROM cimg/python:3.12` (a floating tag) and its `0.0.2` layer is a stale snapshot. This plan cuts a `0.1.0` release of all three images: `django`/`production_django` move to `python:3.12-slim-bookworm` with `poetry` pinned to `2.2.1`, and `circleci_django` gets a plain rebuild against the current `cimg/python:3.12` tag.

## Context

- `django/0.0.2/Dockerfile` and `production_django/0.0.2/Dockerfile` are near-identical: both `FROM python:3.12-slim-bullseye as base`, both install `poetry` via unpinned `pip install --no-cache-dir poetry` (line ~19). `production_django`'s builder stage additionally passes `--only main` to `poetry_builder.sh` — that difference must be preserved.
- `circleci_django/0.0.2/Dockerfile` is `FROM cimg/python:3.12 as base` — already a floating tag, so no `FROM` line change is needed; the fix is simply rebuilding/republishing against today's `cimg/python:3.12` pull.
- `bin/script.sh init django 0.1.0` (see `bin/init.sh`) is the repo's existing tool for cutting a new version: it copies `django/0.0.2` → `django/0.1.0`, `circleci_django/0.0.2` → `circleci_django/0.1.0`, and `production_django/0.0.2` → `production_django/0.1.0` in one call (it always operates on the `""`/`circleci_`/`production_` triple for a given base image name), bumps all three entries in the root `version` file to `0.1.0`, and rewrites any `FROM darthjee/<image>:<old>` lines in the new Dockerfiles to match the versions currently in `version`.
  - Note: this will also rewrite `FROM darthjee/scripts:0.5.0` → `FROM darthjee/scripts:0.9.0` (the `version` file's current `scripts` entry) in the copied `django`/`production_django`/`circleci_django` Dockerfiles — an expected side effect of `init`, not a manual step.
- `.circleci/config.yml`'s `release-django` / `release-circleci_django` / `release-production_django` jobs take the image name as a parameter and aren't pinned to a version — no CI config changes are needed for this bump.

## Implementation Steps

### Step 1 — Cut the new version directories

Run:
```bash
bin/script.sh init django 0.1.0
```
This creates `django/0.1.0/`, `circleci_django/0.1.0/`, `production_django/0.1.0/` (copied from `0.0.2/`), bumps `django=`, `circleci_django=`, and `production_django=` in `version` to `0.1.0`, and updates any `darthjee/*` `FROM` tags in the new Dockerfiles to current `version`-file versions (notably `darthjee/scripts`).

### Step 2 — Bump `django/0.1.0/Dockerfile`

- Change `FROM python:3.12-slim-bullseye as base` → `FROM python:3.12-slim-bookworm as base`.
- Change `RUN pip install --no-cache-dir poetry` → `RUN pip install --no-cache-dir poetry==2.2.1`.
- Leave the rest of the file (package list, builder stage, final stage) unchanged.

### Step 3 — Bump `production_django/0.1.0/Dockerfile`

Same two changes as Step 2 (`python:3.12-slim-bookworm`, `poetry==2.2.1`), applied to `production_django/0.1.0/Dockerfile`. Preserve the existing `--only main` flag on the `poetry_builder.sh` call in the builder stage — do not drop it.

### Step 4 — `circleci_django/0.1.0/Dockerfile`

No content change required — it already builds `FROM cimg/python:3.12`, a floating tag. Leave `circleci_django/0.1.0/Dockerfile` exactly as copied by `init` in Step 1; the package refresh happens naturally when this version is actually built/released against the then-current `cimg/python:3.12` pull.

### Step 5 — Verify locally

For each of the three images:
```bash
bin/script.sh pre_build django
bin/script.sh build django circleci_django production_django
bin/script.sh test django circleci_django production_django
```
Spot-check the base OS and `poetry` version the same way the issue's own investigation did:
```bash
docker run --rm darthjee/django:0.1.0 python --version
docker run --rm darthjee/django:0.1.0 poetry --version   # expect 2.2.1
docker run --rm darthjee/django:0.1.0 cat /etc/os-release # expect Debian 12 (bookworm)
docker run --rm darthjee/production_django:0.1.0 cat /etc/os-release # expect Debian 12 (bookworm)
```

## Files to Change

- `version` — bump `django`, `circleci_django`, `production_django` entries to `0.1.0` (via `bin/script.sh init django 0.1.0`, Step 1).
- `django/0.1.0/Dockerfile` (new, copied from `0.0.2`) — `bookworm` base + pinned `poetry==2.2.1`.
- `production_django/0.1.0/Dockerfile` (new, copied from `0.0.2`) — `bookworm` base + pinned `poetry==2.2.1`, keep `--only main`.
- `circleci_django/0.1.0/Dockerfile` (new, copied from `0.0.2`) — no content change; version bump only.
- `django/0.1.0/home/pyproject.toml`, `production_django/0.1.0/home/pyproject.toml`, `circleci_django/0.1.0/home/pyproject.toml` — carried over as-is by `init` (copied files); no change expected unless `poetry lock`/build surfaces an incompatibility with `poetry==2.2.1` on `bookworm`, in which case adjust as needed.

## CI Checks

No `.circleci/config.yml` changes are needed — `release-django`, `release-circleci_django`, and `release-production_django` are parameterized by image name and already cover whatever version is current in `version`, triggered on tag push. Local equivalents to run before tagging:
- `django/`, `production_django/`, `circleci_django/`: `bin/script.sh pre_build <image>`, `bin/script.sh build <image>`, `bin/script.sh test <image>` (mirrors what `release-<image>` / `release-<image>-arm64` will do on tag push).

## Notes

- `poetry==2.2.1` was the version the issue's own investigation found already resolving on `bullseye`; pinning to it (rather than "latest at release time") was a deliberate scope decision made during discussion of this issue, to keep this bump reproducible and behavior-neutral for `poetry` itself.
- `production_django` was not mentioned in the original GitHub issue body but was added to this issue's scope during discussion, since it shares `django`'s exact base image and unpinned-`poetry` problem.
- Confirm `pyproject.toml`'s Python/dependency constraints still resolve cleanly under `poetry==2.2.1` on `bookworm` before publishing — the issue's inspection did not test the bookworm rebuild itself, only diagnosed the bullseye image in place.
