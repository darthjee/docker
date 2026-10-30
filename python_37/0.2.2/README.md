darthjee/python_37
==================

## About the image

The `darthjee/python_37` image is a Python 3.7 development image built on top of the official `python:3.7.2` image. It is intended to be used as a base for Python projects managed with `pipenv`.

> **Deprecated:** this image is built on an end-of-life base (`python:3.7.2`) and is no longer maintained. Use [`darthjee/python`](https://hub.docker.com/r/darthjee/python) instead.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## Tools

- `pipenv` — installed globally with `pip`

## How to use

This image is intended to be used as a base for Python projects. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/python_37/tags):

```dockerfile
FROM darthjee/python_37:<version>

COPY --chown=app:app Pipfile Pipfile.lock /home/app/app/
RUN pipenv install --deploy
```

Since the default user is `app`, `pipenv` creates the project's virtualenv under `/home/app`; run commands inside it with `pipenv run <command>`.

## License

See the LICENSE file for more information.
