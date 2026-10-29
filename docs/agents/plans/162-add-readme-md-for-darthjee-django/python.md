# Plan: Add README.md for darthjee/django

Issue: [162-add-readme-md-for-darthjee-django.md](../../issues/162-add-readme-md-for-darthjee-django.md)

## Overview
Create `django/0.1.0/README.md` describing the `darthjee/django` image so `bin/push_description.sh` can publish it as the Docker Hub description. Documentation only: no Dockerfile, `pyproject.toml`, `version` or image change.

## Context
- `django/0.1.0/Dockerfile` builds from `python:3.12-slim-bookworm`, creates user `app` (uid 1000), workdir `/home/app/app`, installs `build-essential`, `default-libmysqlclient-dev`, `pkg-config`, `iputils-ping`, `default-mysql-client`, `telnet`, `curl`, and `poetry` via `pip`.
- A builder stage runs `poetry_builder.sh` (from `darthjee/scripts`) against `home/pyproject.toml`; only the downloaded artifacts are copied into the final image at `/home/app/.cache/pypoetry/artifacts/`. Django is therefore **not** installed — the image ships a pre-populated Poetry artifact cache.
- Conventions (settled in #154–#162, to be documented in #187): follow `python_37/0.2.2/README.md`; no version tags or package versions; no architecture claims; dev README does not link to its counterparts.
- In place: no `bin/script.sh init`; `init` copies the whole folder forward later. `django/0.0.2/` stays untouched.

## Implementation Steps

### Step 1 — Create `django/0.1.0/README.md`
Create the file with exactly this content:

````markdown
darthjee/django
===============

## About the image

The `darthjee/django` image is a Python 3.12 development image for Django projects, built on top of the official `python:3.12-slim-bookworm` image. Projects are managed with Poetry.

The image does not ship a ready-to-use virtualenv. Instead, its Poetry artifact cache (`/home/app/.cache/pypoetry/artifacts`) comes pre-populated with the packages most Django projects need, so a project's own `poetry install` reuses them instead of downloading them again.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## Tools

- `poetry` — installed globally with `pip`
- MySQL support: `default-libmysqlclient-dev`, `build-essential` and `pkg-config` (to build `mysqlclient`), plus the `mysql` client
- Network/debug utilities: `ping`, `telnet`, `curl`

## Pre-cached packages

- `django`, `django-admin`, `mysqlclient`, `gunicorn`, `jinja2`
- Development: `pytest`, `pytest-django`, `ruff`, `radon`, `xenon`, `lizard`

Only the cached versions are reused; if your project pins different versions, Poetry downloads those as usual.

## How to use

This image is intended to be used as a base for Django projects. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/django/tags):

```dockerfile
FROM darthjee/django:<version>

COPY --chown=app:app pyproject.toml poetry.lock /home/app/app/
RUN poetry install --no-root
```

Since the default user is `app`, Poetry creates the project's virtualenv under `/home/app`; run commands inside it with `poetry run <command>`.

The cache is only reused when Poetry runs as `app` with its default cache directory; mounting a volume over `/home/app` hides it.

## License

See the LICENSE file for more information.
````

## Files to Change
- `django/0.1.0/README.md` — new file, the Docker Hub description of `darthjee/django`.

## Notes
- Do not add version tags, package versions, architecture claims, a `docker run` example, `virtualenvs.create false` advice, or links to `circleci_django`/`production_django`.
- Until #163 lands, `bin/script.sh push_description django` pushes `darthjee/django` and then exits 1 on the missing `circleci_django` README — expected.
- No automated tests; verified manually on Docker Hub after the next release tag.
