darthjee/python
===============

## About the image

The `darthjee/python` image is a Python 3.12 development image built on top of the official `python:3.12-slim-bookworm` image. It is intended to be used as a base for Python projects managed with `pipenv`.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

The slim base ships no compiler toolchain; projects whose dependencies need to build C extensions must install one (e.g. `build-essential`) on top of this image.

## Tools

- `pipenv` — installed globally with `pip`

## How to use

This image is intended to be used as a base for Python projects. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/python/tags):

```dockerfile
FROM darthjee/python:<version>

COPY --chown=app:app Pipfile Pipfile.lock /home/app/app/
RUN pipenv install --deploy
```

Since the default user is `app`, `pipenv` creates the project's virtualenv under `/home/app`; run commands inside it with `pipenv run <command>`.

## License

See the LICENSE file for more information.
