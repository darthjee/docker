# Issue: Add README.md for darthjee/circleci_python_37

## Description

Add `circleci_python_37/0.2.2/README.md` describing the `darthjee/circleci_python_37` image, so it can be pushed as the image's Docker Hub description by `bin/push_description.sh`.

The image (`circleci_python_37/0.2.2/Dockerfile`) is built from `circleci/python:3.7.2`. As `root` it creates `/home/circleci/project` and chowns `/home/circleci` to `circleci`, sets `WORKDIR /home/circleci/project`, installs `pipenv` with `pip` (unpinned), and runs as `USER circleci`. There is no `home/` folder.

Parent epic: #153

## Problem

`darthjee/circleci_python_37` has no README, so its Docker Hub page has no description, and `bin/script.sh push_description python_37` fails for the whole family with `Error: README not found at circleci_python_37/0.2.2/README.md`.

The image is also doubly stale: Python 3.7 has been end-of-life since June 2023, and `circleci/python` is CircleCI's deprecated legacy image line (superseded by `cimg/python`). Its only published tags, `0.2.2` and `latest`, are from 2019-01-30 and amd64 only.

## Expected Behavior

`circleci_python_37/0.2.2/README.md` exists and accurately describes image `0.2.2` as it is, including a legacy note about the end-of-life base and a link back to `darthjee/python_37`. `bin/script.sh push_description python_37` then succeeds for the whole family, and after the next release the `darthjee/circleci_python_37` Docker Hub page shows the README.

## Solution

### Conventions

- Follow the structure of the merged `circleci_node` and `python_37` READMEs: title underlined with `=`, *About the image*, *Tools*, *How to use*, *License*.
- Add the file **in place** in `circleci_python_37/0.2.2/`: no `bin/script.sh init`, no new version, no rebuild.
- Never hardcode a version tag in usage examples; use `darthjee/circleci_python_37:<version>` and link the Docker Hub tags list.
- Write in English.

### Content

- **Title:** `darthjee/circleci_python_37`, underlined with `=`.
- **About the image:** this intro:

  > The `darthjee/circleci_python_37` image is a CircleCI-optimized Docker image with Python 3.7, built on top of the `circleci/python:3.7.2` image. It is the CircleCI counterpart of [`darthjee/python_37`](https://hub.docker.com/r/darthjee/python_37), designed to run tests for Python projects managed with `pipenv` on circleci.com. Both images ship Python 3.7.2 and `pipenv`, but this one is not built on top of `darthjee/python_37`.

  Immediately after it, this exact note, with no issue link:

  > **Note:** This is a legacy image built on an old, end-of-life base (`circleci/python:3.7.2`, from CircleCI's deprecated legacy image line).

  Then: "Its working directory is `/home/circleci/project`, owned by the `circleci` user, which is also the image's default user." and "The `circleci/python` base already provides git and the usual CircleCI tooling."
- **Tools:** `pipenv` — installed globally with `pip`. No version is listed, because the Dockerfile does not pin one.
- **How to use:** "This image is intended to be used in CircleCI pipelines of Python projects (see the available tags at https://hub.docker.com/r/darthjee/circleci_python_37/tags)." then two numbered usages:
  1. As the CircleCI job executor image, in `.circleci/config.yml`:

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

  2. As a base for projects building their own CI image on top of it, in a `Dockerfile`:

     ```dockerfile
     FROM darthjee/circleci_python_37:<version>

     COPY --chown=circleci:circleci Pipfile Pipfile.lock /home/circleci/project/
     RUN pipenv install --dev --deploy
     ```

  followed by: "Since the default user is `circleci`, `pipenv` creates the project's virtualenv under `/home/circleci`; run commands inside it with `pipenv run <command>`."
- **License:** "See the LICENSE file for more information."
- Use `--dev` (CI needs dev dependencies such as the test runner); `pytest` is only an illustrative test command. Do not show `--system` (site-packages is root-owned). No architecture claims. Do not compare users or working directories with `python_37`.

### Counterparts and layers

- `circleci_python_37` is a counterpart of `python_37` **by name only**: it is built on `circleci/python:3.7.2`, not on `darthjee/python_37`. The `python_37` README (#160) intentionally does not link here and stays untouched; this README links back to it.
- No image builds on `darthjee/circleci_python_37`. `production_python_37` does not exist. The `django` family (Python 3.12 bases) is unrelated.
- No layer impact: the README is never copied into the image.
- Known inaccuracy, left as is: `.claude/agents/python.md` says `circleci_python_37` is "based on `cimg`". It becomes true once #184 rebuilds the image on `cimg/python`.

### Fix vs. new version

- `bin/push_description.sh` resolves the README path from the `version` file (`circleci_python_37=0.2.2`), so the file must live in `circleci_python_37/0.2.2/`.
- No `init`: `init python_37` would bump the whole family and create `0.2.3` folders differing only by the README; versioning belongs to the rebuild in #184.
- `bin/init.sh` copies the whole version folder (`cp -R`), so the README carries over to future versions automatically.
- Once this lands, `push_description python_37` succeeds for the whole family (`production_python_37` is skipped).

### Multi-arch

The published tags are `linux/amd64` only, and so is the base `circleci/python:3.7.2`, so arm64 is not possible on the current base. Multi-arch comes with the rebuild in #184. The README makes no architecture claim.

### Out of scope

- Dockerfile changes, a new version, a rebuild on `cimg/python`, and multi-arch publishing — tracked in #184 (which also notes that this README's legacy note must be dropped on rebuild).
- Pushing the description to Docker Hub — the CI sub-issue of #153.
- Changes to `bin/`, the `version` file, `.claude/agents/python.md`, or the `python_37` README.
- The `django` family, which has its own sub-issues.

### Responsible agent

`python`

### Testing

No automated tests. The user checks manually after the next release that the `darthjee/circleci_python_37` Docker Hub page shows this README.
