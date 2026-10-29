# Plan: Add README.md for darthjee/python_37

Issue: [160-add-readme-md-for-darthjee-python-37.md](../../issues/160-add-readme-md-for-darthjee-python-37.md)

## Overview
Write a new `python_37/0.2.2/README.md` for `darthjee/python_37`, using the same structure as the merged `node/*/README.md` and `node_mongo/*/README.md`. No Dockerfile change, no new version, no rebuild.

## Context
- `python_37/0.2.2/Dockerfile`: `FROM python:3.7.2`. It creates the `app` user (uid 1000) and `/home/app/app`, sets `WORKDIR /home/app/app`, runs `pip install pipenv` (unpinned), then `USER app`. There is no `home/` folder.
- `python:3.7.2` is end-of-life (Python 3.7 since June 2023, on Debian stretch). The rebuild is tracked in #184 and is out of scope.
- `bin/push_description.sh` reads `<image>/<version from version file>/README.md`. `version` has `python_37=0.2.2`.
- `circleci_python_37` is built on `circleci/python:3.7.2`, not on this image. This README does not mention it.

## Implementation Steps

### Step 1 — Write `python_37/0.2.2/README.md`
Create the file with exactly this content:

````markdown
darthjee/python_37
==================

## About the image

The `darthjee/python_37` image is a Python 3.7 development image built on top of the official `python:3.7.2` image. It is intended to be used as a base for Python projects managed with `pipenv`.

> **Note:** This is a legacy image built on an old, end-of-life Python base (`python:3.7.2`).

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
````

Constraints:
- Do not hardcode a version tag in the example.
- No architecture claims.
- No link to `circleci_python_37`.
- Do not show `pipenv install --system`: site-packages is root-owned and the default user is `app`.

## Files to Change
- `python_37/0.2.2/README.md` — new file. It is the Docker Hub description of `darthjee/python_37`.

## Notes
- Do not modify `python_37/0.2.2/Dockerfile`, the `version` file, `bin/`, or any other image.
- `bin/script.sh push_description python_37` will still fail until `circleci_python_37/0.2.2/README.md` exists (its own sub-issue). That is expected.
- No automated tests. The user verifies manually on Docker Hub after the next release.
