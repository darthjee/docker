# Plan: Add README.md for darthjee/circleci_django

Issue: [163-add-readme-md-for-darthjee-circleci-django.md](../../issues/163-add-readme-md-for-darthjee-circleci-django.md)

## Overview
Write `circleci_django/0.1.0/README.md` in place (the folder the root `version` file points to: `circleci_django=0.1.0`). README-only change: no `bin/script.sh init`, no `version` bump, no `pre_build`/`build`/`test`, no `push_description`.

## Context
- Spec: [Image READMEs](../../image-readme.md). Dev README to reuse: `django/0.1.0/README.md` (counterpart rule 4).
- Facts from `circleci_django/0.1.0/Dockerfile`:
  - Base `cimg/python:3.12` (supported — no legacy note); not built on `darthjee/django` → counterpart **by name only**, one-way link to `https://hub.docker.com/r/darthjee/django`.
  - Default user `circleci`; working directory `/home/circleci/project`, owned by `circleci`.
  - Poetry is **not** installed by the Dockerfile; it comes from the `cimg/python` base (no version stated). The base also provides git and the usual CircleCI tooling.
  - Added packages: `pkg-config`, `iputils-ping` (`ping`), `default-mysql-client` (`mysql` client). List only these (decided in the issue).
  - `home/pyproject.toml` is identical to `django`'s; `poetry_builder.sh` installs all groups, so the cache `/home/circleci/.cache/pypoetry/artifacts` holds the same main + dev packages.
- Rules: no `darthjee/` tags (use `<version>`), no tool/package versions, no architecture claims, absolute links only, plain-text license line.

## Implementation Steps

### Step 1 — Write the README
Create `circleci_django/0.1.0/README.md` with this content (adjust wording only if a fact turns out wrong against the Dockerfile):

````markdown
darthjee/circleci_django
========================

## About the image

The `darthjee/circleci_django` image is a CircleCI-optimized Docker image for Django projects managed with Poetry, built on top of the `cimg/python:3.12` image. It is the CircleCI counterpart of [`darthjee/django`](https://hub.docker.com/r/darthjee/django), designed to run tests for Django projects on circleci.com. Both images pre-cache the same packages, but this one is not built on top of `darthjee/django`.

The `cimg/python` base already provides Poetry, git and the usual CircleCI tooling.

The image does not ship a ready-to-use virtualenv. Instead, its Poetry artifact cache (`/home/circleci/.cache/pypoetry/artifacts`) comes pre-populated with the packages most Django projects need, so a project's own `poetry install` reuses them instead of downloading them again.

Its working directory is `/home/circleci/project`, owned by the `circleci` user, which is also the image's default user.

## Tools

- `poetry` — provided by the `cimg/python` base
- MySQL support: `pkg-config` and the `mysql` client
- Network/debug utilities: `ping`

## Pre-cached packages

- `django`, `django-admin`, `mysqlclient`, `gunicorn`, `jinja2`
- Development: `pytest`, `pytest-django`, `ruff`, `radon`, `xenon`, `lizard`

Only the cached versions are reused; if your project pins different versions, Poetry downloads those as usual.

## How to use

This image is intended to be used in CircleCI pipelines of Django projects (see the available tags at https://hub.docker.com/r/darthjee/circleci_django/tags).

1. As the CircleCI job executor image, in your `.circleci/config.yml`:

   ```yaml
   jobs:
     test:
       docker:
         - image: darthjee/circleci_django:<version>
       steps:
         - checkout
         - run: poetry install --no-root
         - run: poetry run pytest
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_django:<version>

   COPY --chown=circleci:circleci pyproject.toml poetry.lock /home/circleci/project/
   RUN poetry install --no-root
   ```

Since the default user is `circleci`, Poetry creates the project's virtualenv under `/home/circleci`; run commands inside it with `poetry run <command>`.

The cache is only reused when Poetry runs as `circleci` with its default cache directory; mounting a volume over `/home/circleci` hides it.

## License

See the LICENSE file for more information.
````

Check: the `=` underline is exactly 24 characters (length of `darthjee/circleci_django`).

## Files to Change
- `circleci_django/0.1.0/README.md` — new file (Docker Hub description).

## Notes
- No CI checks needed: the image is unchanged (spec exception to CI Checks).
- Do not run `bin/script.sh push_description django`: it exits 1 until `production_django` (#164) has its README.
- Do not touch `circleci_django/0.0.2/` or any `django`/`production_django` file.
