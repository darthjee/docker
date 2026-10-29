# Issue: Add README.md for darthjee/django

## Description

Add `django/0.1.0/README.md` describing the `darthjee/django` image, so it is published as the Docker Hub description of `darthjee/django` by `bin/push_description.sh`. The image is built from `python:3.12-slim-bookworm` (see `django/0.1.0/Dockerfile`).

Parent epic: #153. Related: #187 (README conventions spec).

## Problem

`django/0.1.0/` has no `README.md`, so the `darthjee/django` Docker Hub page has no description and `bin/script.sh push_description django` fails for the family. The image's key feature is also non-obvious: it does not ship Django installed, but a pre-populated Poetry artifact cache, which users need explained.

## Expected Behavior

- `django/0.1.0/README.md` exists, following the agreed content below.
- `push_description django` pushes `darthjee/django` successfully (then exits 1 on `circleci_django` until #163 lands).
- After the next release tag, the `darthjee/django` Docker Hub page shows this README.

## Solution

### Conventions

- Follow the structure of the already-merged family READMEs (e.g. `python_37/0.2.2/README.md`): `darthjee/django` title, *About the image*, tools, *How to use*, *License*.
- Add the file **in place** in the current version folder (`django/0.1.0/`): no `bin/script.sh init`, no new version, no rebuild. `README.md` sits beside `home/` and is never copied into the image.
- Do **not** hardcode a version tag in usage examples (use e.g. `FROM darthjee/django:<version>` and point to the Docker Hub tags list), so the README does not go stale on future `init`s.
- Write in English.

### Content

Agreed content for `django/0.1.0/README.md`:

- **About the image:** Python 3.12 development image for Django projects, built on top of `python:3.12-slim-bookworm`, managed with Poetry. State explicitly that the image does **not** ship a ready-to-use virtualenv: its Poetry artifact cache (`/home/app/.cache/pypoetry/artifacts`) is pre-populated (by `poetry_builder.sh` from `darthjee/scripts`, run against `home/pyproject.toml` at build time), so the project's own `poetry install` reuses those artifacts instead of downloading them. Working directory `/home/app/app`, owned by `app` (uid 1000), the default user.
- **Tools:** `poetry` (installed globally with `pip`); MySQL support (`default-libmysqlclient-dev`, `build-essential`, `pkg-config` to build `mysqlclient`, plus the `mysql` client); network/debug utilities (`ping`, `telnet`, `curl`).
- **Pre-cached packages:** `django`, `django-admin`, `mysqlclient`, `gunicorn`, `jinja2`; development: `pytest`, `pytest-django`, `ruff`, `radon`, `xenon`, `lizard`. Note that only matching versions are reused; differently pinned versions are downloaded as usual.
- **No versions** for packages, Poetry, or the base image beyond Python 3.12 (implied by the base tag): `home/pyproject.toml` may change in later versions while `init` copies the README forward unchanged.
- **How to use:** link to https://hub.docker.com/r/darthjee/django/tags, then:

  ```dockerfile
  FROM darthjee/django:<version>

  COPY --chown=app:app pyproject.toml poetry.lock /home/app/app/
  RUN poetry install --no-root
  ```

  No `virtualenvs.create false` advice, no `docker run` example.
- **After the usage example**, two sentences covering edge cases:
  - "Since the default user is `app`, Poetry creates the project's virtualenv under `/home/app`; run commands inside it with `poetry run <command>`."
  - "The cache is only reused when Poetry runs as `app` with its default cache directory; mounting a volume over `/home/app` hides it."
- Not documented (general Poetry behavior): lock files from much older Poetry versions; `mysqlclient` being compiled from source when no matching wheel is cached (implied by the build tools listed).
- **License:** "See the LICENSE file for more information."

### Fix vs. new version

In-place fix: create `django/0.1.0/README.md` in the current version folder (the one `version` points to, and the one `bin/push_description.sh` reads). No `bin/script.sh init`, no version bump, no rebuild: the README sits beside `home/` and the Dockerfile only copies `home/*`, so the image is unchanged. Future `init`s copy the whole folder (`cp -R`), so the README carries forward. The legacy `django/0.0.2/` folder is left untouched.

Expected interim state: until the `circleci_django` and `production_django` READMEs land, `push_description django` pushes `darthjee/django` and then exits 1 on the missing `circleci_django` README.

### Counterparts and layers

- None. No image in the repo builds `FROM darthjee/django`.
- Counterparts: `circleci_django` (#163) is a counterpart by name only (built on `cimg/python:3.12`, same `pyproject.toml`/pre-populated cache under `/home/circleci/project` as `circleci`); `production_django` (#164) uses the same Dockerfile but caches main dependencies only (`--only main`). Both will reuse this README's structure and link back to `darthjee/django`; this README does not link to them (as with `python_37`).
- Pushing to Docker Hub is handled separately by the CI sub-issue (release job pushes descriptions); this sub-issue only adds the file.
- Layer impact: none — the README is never copied into the image.

### Multi-arch

No architecture claim in the README (Docker Hub currently has amd64 only for this image).

### Out of scope

- The `circleci_django` (#163) and `production_django` (#164) READMEs.
- The README conventions spec (#187).
- Any Dockerfile, `pyproject.toml` or version change.

### Responsible agent

`python`

### Testing

No automated tests. Verified manually after the next release tag: the `darthjee/django` Docker Hub page shows this README.
