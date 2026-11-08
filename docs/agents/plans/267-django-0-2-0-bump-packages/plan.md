# Plan: django 0.2.0: bump packages

Issue: [267-django-0-2-0-bump-packages.md](../../issues/267-django-0-2-0-bump-packages.md)

## Overview
Create `0.2.0` for `django`, `circleci_django` and `production_django`:
- pinned Python 3.12.16 bases
- `scripts:0.15.0`
- poetry 2.5.1 pinned through an ARG in all three images
- Django 5.2.19 (LTS) and refreshed `pyproject.toml` dependencies

See [python.md](python.md) for the full plan.
