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
