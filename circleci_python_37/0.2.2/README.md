darthjee/circleci_python_37
===========================

## About the image

The `darthjee/circleci_python_37` image is a CircleCI-optimized Docker image with Python 3.7, built on top of the `circleci/python:3.7.2` image. It is the CircleCI counterpart of [`darthjee/python_37`](https://hub.docker.com/r/darthjee/python_37), designed to run tests for Python projects managed with `pipenv` on circleci.com. Both images ship Python 3.7.2 and `pipenv`, but this one is not built on top of `darthjee/python_37`.

> **Note:** This is a legacy image built on an old, end-of-life base (`circleci/python:3.7.2`, from CircleCI's deprecated legacy image line).

Its working directory is `/home/circleci/project`, owned by the `circleci` user, which is also the image's default user.

The `circleci/python` base already provides git and the usual CircleCI tooling.

## Tools

- `pipenv` — installed globally with `pip`

## How to use

This image is intended to be used in CircleCI pipelines of Python projects (see the available tags at https://hub.docker.com/r/darthjee/circleci_python_37/tags).

1. As the CircleCI job executor image, in your `.circleci/config.yml`:

   ```yaml
   jobs:
     test:
       docker:
         - image: darthjee/circleci_python_37:<version>
       steps:
         - checkout
         - run: pipenv install --dev --deploy
         - run: pipenv run pytest
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_python_37:<version>

   COPY --chown=circleci:circleci Pipfile Pipfile.lock /home/circleci/project/
   RUN pipenv install --dev --deploy
   ```

Since the default user is `circleci`, `pipenv` creates the project's virtualenv under `/home/circleci`; run commands inside it with `pipenv run <command>`.

## License

See the LICENSE file for more information.
