# Plan: Rebuild darthjee/python_37 on a supported Python base

Issue: [184-rebuild-darthjee-python-37-on-a-supported-python-base.md](../../issues/184-rebuild-darthjee-python-37-on-a-supported-python-base.md)

## Overview
Add two new image families, `darthjee/python` (on `python:3.12-slim-bookworm`) and `darthjee/circleci_python` (on `cimg/python:3.12`), both starting at `0.1.0` and shipping `pipenv`. Wire them into the version file, CI release jobs, the root README, docs and agent definitions. Keep `python_37` and `circleci_python_37`, but mark them deprecated and point them to the new images.

See [python.md](python.md) for the full plan.
