# Issue: Add README.md for darthjee/circleci_django

## Description

Add `circleci_django/0.1.0/README.md` describing the `darthjee/circleci_django` image, so it can be pushed as the Docker Hub description of `darthjee/circleci_django` (see `bin/push_description.sh`). Today the image has no README, so its Docker Hub page has no description, and `bin/script.sh push_description django` stops at this missing file.

Parent epic: #153

## Problem

`bin/script.sh push_description django` pushes the whole Django family (`django`, `circleci_django`, `production_django`) and exits 1 on the first missing README. `darthjee/django` now has its README (#162), but `circleci_django` does not, so the family still cannot be published.

## Expected Behavior

- `circleci_django/0.1.0/README.md` exists, written following [Image READMEs](docs/agents/image-readme.md).
- Once `production_django` (#164) also has its README, `bin/script.sh push_description django` succeeds for the whole family.

## Solution

Write the README following `docs/agents/image-readme.md`, reusing the structure and wording of `django/0.1.0/README.md` (counterpart rule 4) and changing only what differs. Every statement is derived from `circleci_django/0.1.0/Dockerfile`, `circleci_django/0.1.0/home/pyproject.toml` and `poetry_builder.sh`.

### Facts from the Dockerfile

- Built on `cimg/python:3.12` (supported base: **no** legacy note). Python 3.12 may be stated (part of the base's identity).
- It is **not** built on top of `darthjee/django`: it is the CircleCI counterpart **by name only** (parallel image). The intro says so and links `https://hub.docker.com/r/darthjee/django` (one-way link).
- Default user `circleci`; working directory `/home/circleci/project`, owned by `circleci`.
- The `cimg/python` base already provides Poetry, git and the usual CircleCI tooling. The Dockerfile does not install Poetry itself (unlike `darthjee/django`), so the README says Poetry comes from the base, without a version.
- Added on top of the base: `pkg-config`, `ping` (`iputils-ping`) and the `mysql` client (`default-mysql-client`). Unlike `darthjee/django`, it does not install `build-essential`, `default-libmysqlclient-dev`, `telnet` or `curl` explicitly; the README lists only what the Dockerfile adds.
- Same `pyproject.toml` as `darthjee/django`. `poetry_builder.sh` runs `poetry install --no-root` with **all** groups, so the Poetry artifact cache (`/home/circleci/.cache/pypoetry/artifacts`) is pre-populated with the same main **and** dev packages as `darthjee/django`.

### Sections

1. Title `darthjee/circleci_django` underlined with `=`.
2. `## About the image`: CircleCI image for Django projects managed with Poetry, on `cimg/python:3.12`; counterpart-by-name intro linking `darthjee/django`; what the base provides; user/working directory.
3. `## Tools`: MySQL support (`pkg-config`, `mysql` client), network/debug (`ping`); Poetry noted as coming from the base.
4. `## Pre-cached packages`: same list as `darthjee/django` (`django`, `django-admin`, `mysqlclient`, `gunicorn`, `jinja2`; development: `pytest`, `pytest-django`, `ruff`, `radon`, `xenon`, `lizard`), names only, plus the cache path and the "only cached versions are reused" sentence.
5. `## How to use`: tags link `https://hub.docker.com/r/darthjee/circleci_django/tags`; (1) CircleCI executor example (`image: darthjee/circleci_django:<version>`, `checkout`, `poetry install --no-root`, `poetry run pytest`); (2) `Dockerfile` example `FROM darthjee/circleci_django:<version>` copying `pyproject.toml poetry.lock` to `/home/circleci/project/` with `--chown=circleci:circleci`; the virtualenv/`poetry run` sentence and the cache-reuse sentence adapted to `circleci`/`/home/circleci`.
6. `## License`: "See the LICENSE file for more information."

### Process

- Add the file **in place** in `circleci_django/0.1.0/` (the folder `version` points to): no `bin/script.sh init`, no version bump, no `pre_build`/`build`/`test` run.
- No `darthjee/` tags, no tool/package versions, no architecture claims, absolute links only.
- Do not run `push_description` in this issue: the family push needs #164 first, and publishing is handled by #171 / a manual run.

### Responsible agent

`python`

### Testing

No automated tests. After #164 lands and `bin/script.sh push_description django` runs, the `darthjee/circleci_django` Docker Hub page shows this README.

## Benefits

- `darthjee/circleci_django` gets a Docker Hub description consistent with `darthjee/django`.
- Unblocks the Django family push once #164 is done.
