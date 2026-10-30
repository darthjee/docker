# Deprecate python_37 and circleci_python_37
Keep both legacy images and their CI release jobs, but mark them as deprecated in their Docker Hub descriptions. Editing the README of the current released version in place is allowed by the README exception in `docs/agents/image-readme.md`. Do not touch the Dockerfiles.

In each README, replace the existing legacy note with a deprecation note:
- `python_37`: "**Deprecated:** this image is built on an end-of-life base (`python:3.7.2`) and is no longer maintained. Use [`darthjee/python`](https://hub.docker.com/r/darthjee/python) instead."
- `circleci_python_37`: the same note, pointing to [`darthjee/circleci_python`](https://hub.docker.com/r/darthjee/circleci_python).

The descriptions are pushed after release, either by the CI `release` job or by hand with `bin/script.sh push_description python_37 circleci_python_37`.

## Files to Change
- `python_37/0.2.2/README.md` — replace the legacy note with a deprecation note pointing to `darthjee/python`
- `circleci_python_37/0.2.2/README.md` — replace the legacy note with a deprecation note pointing to `darthjee/circleci_python`
