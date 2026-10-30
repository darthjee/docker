# Wire the new images into root files and docs
Register the new families everywhere the repo lists images. These are root-level files, so the architect does this step (see the Notes in `python.md`).

- `version`: add `python=0.1.0` under `# Development` and `circleci_python=0.1.0` under `# Circleci`. Keep the `python_37` / `circleci_python_37` entries.
- `.circleci/config.yml`: add `release-python` (image `python`, `filters: *tag_only`, no `requires`) next to `release-python_37`, and `release-circleci_python` next to `release-circleci_python_37`.
- `.claude/scripts/check_python.sh`: loop over `python django` (and `circleci_python`) instead of `python_37 django`, so the agent's check covers the new images.
- `README.md` (root): list `python` and `circleci_python` in the Development / Circleci image lists, and mark `python_37` / `circleci_python_37` as deprecated.
- `docs/agents/folder-structure.md`: add a `python/` row ("Python development image (pipenv)") and mark `python_37/` as deprecated.
- `docs/agents/architecture.md`: add `python` to the "no tests for" example list (line ~90).
- `docs/agents/image-readme.md`: point the reference examples and the `## Tools` example at `python/0.1.0/README.md`. Keep the `circleci_python_37` row as the "legacy base" example and update its description to say "deprecated".
- `.claude/agents/python.md`: extend the description and scope to `python/` and `circleci_python/`. Mark `python_37/` and `circleci_python_37/` as deprecated, and note `pipenv` for the `python` family under Stack.
- `.claude/agents/architect.md`: update the roster row for `python` to `python/`, `python_37/` (deprecated), `django/` + counterparts.

## Files to Change
- `version` — add `python=0.1.0` and `circleci_python=0.1.0`
- `.circleci/config.yml` — add `release-python` and `release-circleci_python` jobs
- `.claude/scripts/check_python.sh` — build/test the new images
- `README.md` — list the new images and mark the old ones deprecated
- `docs/agents/folder-structure.md` — new `python/` row, `python_37/` marked deprecated
- `docs/agents/architecture.md` — add `python` to the no-tests example list
- `docs/agents/image-readme.md` — reference the new READMEs
- `.claude/agents/python.md` — extend scope to the new folders
- `.claude/agents/architect.md` — update the roster row
