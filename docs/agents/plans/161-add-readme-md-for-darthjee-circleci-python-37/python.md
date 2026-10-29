# Plan: Add README.md for darthjee/circleci_python_37

Issue: [161-add-readme-md-for-darthjee-circleci-python-37.md](../../issues/161-add-readme-md-for-darthjee-circleci-python-37.md)

## Overview
Create a single new file, `circleci_python_37/0.2.2/README.md`, documenting image `0.2.2` as it is (legacy `circleci/python:3.7.2` base), following the structure of the merged `circleci_node` and `python_37` READMEs. No Dockerfile change, no `bin/script.sh init`, no rebuild.

## Context
- `circleci_python_37/0.2.2/Dockerfile`: `FROM circleci/python:3.7.2`; as `root` it creates `/home/circleci/project` and chowns `/home/circleci` to `circleci`; `WORKDIR /home/circleci/project`; `pip install pipenv` (unpinned); `USER circleci`. There is no `home/` folder.
- `bin/push_description.sh` reads `<image>/<version from the version file>/README.md`; `version` has `circleci_python_37=0.2.2`, so the file must be in `circleci_python_37/0.2.2/`. With this file in place, `push_description python_37` succeeds for the whole family (`python_37` already has its README from #160; `production_python_37` does not exist and is skipped).
- It is a counterpart of `darthjee/python_37` by name only: it is not built on it. The `python_37` README intentionally does not link here and must not be changed.
- Python 3.7 is end-of-life and `circleci/python` is CircleCI's deprecated legacy line; the rebuild is tracked in #184.

## Implementation Steps

### Step 1 — Create `circleci_python_37/0.2.2/README.md`
Create the file with exactly this content:

````markdown
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
````

Rules: no hardcoded version tags; no architecture claims; no `--system`; no `pipenv` version; no link to #184; do not compare users/working directories with `python_37`. The title underline must be exactly as long as the title (27 `=`).

## Files to Change
- `circleci_python_37/0.2.2/README.md` — new file, the Docker Hub description of `darthjee/circleci_python_37`.

## Notes
- No automated tests; the README is never copied into the image, so no build/CI check is needed. The user verifies the Docker Hub page manually after the next release.
- Out of scope: `circleci_python_37/0.2.2/Dockerfile`, `version`, `bin/`, `python_37/0.2.2/README.md`, and `.claude/agents/python.md` (its "based on `cimg`" wording is a known inaccuracy, left for #184).
