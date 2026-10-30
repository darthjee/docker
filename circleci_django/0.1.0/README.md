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
