darthjee/circleci_python
========================

## About the image

The `darthjee/circleci_python` image is a CircleCI-optimized Docker image with Python 3.12, built on top of the `cimg/python:3.12` image. It is the CircleCI counterpart of [`darthjee/python`](https://hub.docker.com/r/darthjee/python), designed to run tests for Python projects managed with `pipenv` on circleci.com. Both images ship Python 3.12 and `pipenv`, but this one is not built on top of `darthjee/python`.

Its working directory is `/home/circleci/project`, owned by the `circleci` user, which is also the image's default user.

The `cimg/python` base already provides git, a compiler toolchain and the usual CircleCI tooling.

## Tools

- `pipenv` — provided by the `cimg/python` base

## How to use

This image is intended to be used in CircleCI pipelines of Python projects (see the available tags at https://hub.docker.com/r/darthjee/circleci_python/tags).

1. As the CircleCI job executor image, in your `.circleci/config.yml`:

   ```yaml
   jobs:
     test:
       docker:
         - image: darthjee/circleci_python:<version>
       steps:
         - checkout
         - run: pipenv install --dev --deploy
         - run: pipenv run pytest
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_python:<version>

   COPY --chown=circleci:circleci Pipfile Pipfile.lock /home/circleci/project/
   RUN pipenv install --dev --deploy
   ```

Since the default user is `circleci`, `pipenv` creates the project's virtualenv under `/home/circleci`; run commands inside it with `pipenv run <command>`.

## License

See the LICENSE file for more information.
