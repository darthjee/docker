# Plan: Add README.md for darthjee/production_django

Issue: [164-add-readme-md-for-darthjee-production-django.md](../../issues/164-add-readme-md-for-darthjee-production-django.md)

## Overview
Write `production_django/0.1.0/README.md` in place (the folder the root `version` file points to: `production_django=0.1.0`). README-only change: no `bin/script.sh init`, no `version` bump, no `pre_build`/`build`/`test`, no `push_description` (pushing is #171's job).

## Context
- Spec: [Image READMEs](../../image-readme.md). Dev README to reuse: `django/0.1.0/README.md` (counterpart rule 4).
- Facts from `production_django/0.1.0/Dockerfile`:
  - Base `python:3.12-slim-bookworm` (supported — no legacy note), the same base as `darthjee/django`; not built on `darthjee/django` → production counterpart **by name only**, one-way link to `https://hub.docker.com/r/darthjee/django`.
  - Default user `app` (uid 1000); working directory `/home/app/app`, owned by `app`.
  - System packages: same as `django` — `build-essential`, `default-libmysqlclient-dev`, `pkg-config`, `default-mysql-client`, `iputils-ping`, `telnet`, `curl`.
  - `poetry` installed globally with `pip` (pinned in the Dockerfile; do not state the version).
  - `poetry_builder.sh --only main` → the cache `/home/app/.cache/pypoetry/artifacts` holds the **main** group only: `django`, `django-admin`, `mysqlclient`, `gunicorn`, `jinja2`. No dev packages.
- Intro wording decided in the issue: "caching only the main (non-development) dependencies" (adapts the spec's "without development dependencies", since system tools are identical).
- Rules: no `darthjee/` tags (use `<version>`), no tool/package versions, no architecture claims, absolute links only, plain-text license line.

## Implementation Steps

### Step 1 — Write the README
Create `production_django/0.1.0/README.md` with this content (adjust wording only if a fact turns out wrong against the Dockerfile):

````markdown
darthjee/production_django
==========================

## About the image

The `darthjee/production_django` image is a Python 3.12 production image for Django projects, built on top of the official `python:3.12-slim-bookworm` image. Projects are managed with Poetry. It is the production counterpart of [`darthjee/django`](https://hub.docker.com/r/darthjee/django), caching only the main (non-development) dependencies. Both images share the same base and tools, but this one is not built on top of `darthjee/django`.

The image does not ship a ready-to-use virtualenv. Instead, its Poetry artifact cache (`/home/app/.cache/pypoetry/artifacts`) comes pre-populated with the main packages most Django projects need, so a project's own `poetry install` reuses them instead of downloading them again.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## Tools

- `poetry` — installed globally with `pip`
- MySQL support: `default-libmysqlclient-dev`, `build-essential` and `pkg-config` (to build `mysqlclient`), plus the `mysql` client
- Network/debug utilities: `ping`, `telnet`, `curl`

## Pre-cached packages

- `django`, `django-admin`, `mysqlclient`, `gunicorn`, `jinja2`

Only the cached versions are reused; if your project pins different versions, Poetry downloads those as usual.

## How to use

This image is intended to be used as a base for Django projects in production. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_django/tags):

```dockerfile
FROM darthjee/production_django:<version>

COPY --chown=app:app pyproject.toml poetry.lock /home/app/app/
RUN poetry install --only main --no-root
```

Since the default user is `app`, Poetry creates the project's virtualenv under `/home/app`; run commands inside it with `poetry run <command>`.

The cache is only reused when Poetry runs as `app` with its default cache directory; mounting a volume over `/home/app` hides it.

## License

See the LICENSE file for more information.
````

Check: the `=` underline is exactly 26 characters (length of `darthjee/production_django`).

## Files to Change
- `production_django/0.1.0/README.md` — new file (Docker Hub description).

## Notes
- No CI checks needed: the image is unchanged (spec exception to CI Checks).
- Do not run `bin/script.sh push_description django`; pushing is handled by #171.
- Do not touch `production_django/0.0.2/` or any `django`/`circleci_django` file.
