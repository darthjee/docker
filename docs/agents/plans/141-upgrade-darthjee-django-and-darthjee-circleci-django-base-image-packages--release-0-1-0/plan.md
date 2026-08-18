# Plan: Upgrade darthjee/django and darthjee/circleci_django base image packages (release 0.1.0)

Issue: [141-upgrade-darthjee-django-and-darthjee-circleci-django-base-image-packages--release-0-1-0.md](../../issues/141-upgrade-darthjee-django-and-darthjee-circleci-django-base-image-packages--release-0-1-0.md)

## Overview

Release `0.1.0` of `django`, `production_django`, and `circleci_django`: move `django`/`production_django` off Debian `bullseye` (`oldoldstable`) to `python:3.12-slim-bookworm` with `poetry` pinned to `2.2.1`, and cut a fresh `circleci_django` build against the current `cimg/python:3.12` tag (no Dockerfile change needed there). All three images are entirely within the `python` specialist's scope.

See [python.md](python.md) for the full plan.
