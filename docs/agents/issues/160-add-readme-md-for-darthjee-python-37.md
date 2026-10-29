# Issue: Add README.md for darthjee/python_37

## Description

Add `python_37/0.2.2/README.md` describing the `darthjee/python_37` image, so it can be pushed as the image's Docker Hub description by `bin/push_description.sh`.

The image (`python_37/0.2.2/Dockerfile`) is built from `python:3.7.2`, creates the `app` user (uid 1000) with working directory `/home/app/app`, installs `pipenv` with `pip`, and runs as `USER app`. There is no `home/` folder.

Parent epic: #153

## Problem

`darthjee/python_37` has no README, so its Docker Hub page has no description and `bin/script.sh push_description python_37` fails with `Error: README not found at python_37/0.2.2/README.md`.

The image is also built on an end-of-life base: Python 3.7 since June 2023, on Debian stretch. Its only published tags, `0.2.2` and `latest`, are from 2019-01-30 and amd64 only.

## Expected Behavior

`python_37/0.2.2/README.md` exists and accurately describes image `0.2.2` as it is, including a legacy note about the end-of-life base. After the next release, the `darthjee/python_37` Docker Hub page shows it.

## Solution

### Conventions

- Follow the structure of the merged `node` and `node_mongo` READMEs (themselves modelled on `circleci_rails_gems/2.1.1/README.md`): title underlined with `=`, *About the image*, a tools section, *How to use*, *License*.
- Add the file **in place** in `python_37/0.2.2/`: no `bin/script.sh init`, no new version, no rebuild.
- Never hardcode a version tag in usage examples; use `FROM darthjee/python_37:<version>` and link the Docker Hub tags list.
- Write in English.

### Content

- **Title:** `darthjee/python_37`, underlined with `=`.
- **About the image:** a Python 3.7 development image built on the official `python:3.7.2` image, intended as a base for Python projects managed with `pipenv`. Immediately after the intro, this exact note, with no issue link:

  > **Note:** This is a legacy image built on an old, end-of-life Python base (`python:3.7.2`).

  The working directory is `/home/app/app`, owned by the `app` user (uid 1000), which is also the image's default user.
- **Tools:** `pipenv`, installed globally with `pip`. No version is listed, because the Dockerfile does not pin one.
- **How to use:** a link to https://hub.docker.com/r/darthjee/python_37/tags, then:

  ```dockerfile
  FROM darthjee/python_37:<version>

  COPY --chown=app:app Pipfile Pipfile.lock /home/app/app/
  RUN pipenv install --deploy
  ```

  followed by one sentence: because the default user is `app`, `pipenv` creates the project's virtualenv under `/home/app`, and commands run with `pipenv run <command>`. Do not show `--system`, because site-packages is root-owned.
- **License:** "See the LICENSE file for more information."
- No architecture claims, and no mention of `circleci_python_37`.

### Counterparts and layers

- `circleci_python_37` is a counterpart **by name only**: it is built on `circleci/python:3.7.2`, not on `darthjee/python_37`. The `django` family uses Python 3.12 bases and is unrelated. No image builds on `darthjee/python_37`.
- Following #158 and #159, this README does not link to `circleci_python_37`. That image's own README, written in its sub-issue, links back here.
- No layer impact: the README is never copied into the image.

### Fix vs. new version

- `bin/push_description.sh` resolves the README path from the `version` file (`python_37=0.2.2`), so the file must live in the current version folder.
- `bin/init.sh` copies the whole version folder (`cp -R`), so the README carries over to future versions automatically.
- `push_description python_37` pushes the whole family and exits 1 while `circleci_python_37/0.2.2/README.md` is missing. That is expected until the sibling sub-issue is merged, and it is the CI sub-issue's concern.

### Multi-arch

The published tags are `linux/amd64` only. This issue changes nothing about the image, and the README makes no architecture claim (Docker Hub already shows each tag's architectures).

### Out of scope

- Dockerfile changes, a new version, a rebuild, and multi-arch publishing. These are tracked in #184.
- Pushing the description to Docker Hub, which is the CI sub-issue of #153.
- `circleci_python_37`, its README, and the `django` family, which have their own sub-issues.
- Changes to `bin/push_description.sh` or the `version` file.

### Responsible agent

`python`

### Testing

No automated tests. The user checks manually after the next release that the `darthjee/python_37` Docker Hub page shows this README.
