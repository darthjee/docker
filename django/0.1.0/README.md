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
