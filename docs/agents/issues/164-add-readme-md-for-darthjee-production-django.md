## Description

Add `production_django/0.1.0/README.md` describing the `darthjee/production_django` image, so it can be pushed as the Docker Hub description of `darthjee/production_django` (see `bin/push_description.sh`). Today the image has no README, so its Docker Hub page has no description, and `bin/script.sh push_description django` fails for the whole family: `django` and `circleci_django` already have READMEs, and `production_django` is the last one missing.

Write it following [`docs/agents/image-readme.md`](../image-readme.md), reusing the structure and wording of [`django/0.1.0/README.md`](../../../django/0.1.0/README.md) and changing only what differs for production.

## Facts from the image (`production_django/0.1.0/Dockerfile`)

- Built `FROM python:3.12-slim-bookworm` — the same base as `darthjee/django`, **not** `FROM darthjee/django`: it is a production counterpart by name only (parallel image). The base is supported, so no legacy note.
- Default user `app` (uid 1000); working directory `/home/app/app`, owned by `app`.
- System packages: `build-essential`, `default-libmysqlclient-dev`, `pkg-config` (to build `mysqlclient`), `default-mysql-client`, `iputils-ping`, `telnet`, `curl` — the same list as `darthjee/django`.
- `poetry` installed globally with `pip` (the version is pinned in the Dockerfile but must not be written in the README).
- `poetry_builder.sh --only main` pre-populates `/home/app/.cache/pypoetry/artifacts` with the **main** group only of `home/pyproject.toml` (identical to `django`'s): `django`, `django-admin`, `mysqlclient`, `gunicorn`, `jinja2`. The development group (`pytest`, `pytest-django`, `ruff`, `radon`, `xenon`, `lizard`) is not cached.

## Sections to write

- Title `darthjee/production_django`, underlined with `=` to its length.
- **About the image:** a Python 3.12 production image for Django projects on `python:3.12-slim-bookworm`; "the production counterpart of [`darthjee/django`](https://hub.docker.com/r/darthjee/django), caching only the main (non-development) dependencies", stating it is not built on top of it. (This adapts the spec's "without development dependencies": the system tools are the same as django's; only the Poetry cache differs.) Then the cache paragraph (main dependencies only) and the user/working-directory paragraph, reusing django's wording.
- **Tools:** same as django's list.
- **Pre-cached packages:** main packages only, followed by the "Only the cached versions are reused…" sentence.
- **How to use:** link to https://hub.docker.com/r/darthjee/production_django/tags; a `Dockerfile` example `FROM darthjee/production_django:<version>` that copies `pyproject.toml poetry.lock` and runs `poetry install --only main --no-root`; the virtualenv and cache sentences from django.
- **License:** "See the LICENSE file for more information."

## Process

- Add the file **in place** in `production_django/0.1.0/` (the folder `version` points to): no `bin/script.sh init`, no version bump, no `pre_build`/`build`/`test`. `README.md` sits beside `home/` and is never copied into the image.
- No hardcoded `darthjee/` tags, no tool/package versions, no architecture claims, absolute links only.
- Write in English.

## Dependencies

- Builds on #162 (`django` README) and #163 (`circleci_django` README), both merged.
- Pushing to Docker Hub is handled separately (#171, release job pushes descriptions); this issue only adds the file.

## Responsible agent

`python`

## Testing

No automated tests. Check the README against the spec's content rules. Verified manually once descriptions are pushed: the `darthjee/production_django` Docker Hub page shows this README.

Parent epic: #153
