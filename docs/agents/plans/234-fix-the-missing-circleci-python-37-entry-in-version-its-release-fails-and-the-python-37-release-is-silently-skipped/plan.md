# Plan: Fix the missing `circleci_python_37` entry in `version` (its release fails and the `python_37` release is silently skipped)

Issue: [234-fix-the-missing-circleci-python-37-entry-in-version-its-release-fails-and-the-python-37-release-is-silently-skipped.md](../../issues/234-fix-the-missing-circleci-python-37-entry-in-version-its-release-fails-and-the-python-37-release-is-silently-skipped.md)

## Overview

Put back the `circleci_python_37=0.2.2` entry in the root `version` file. Then make `image_version()` in `bin/image.sh` fail loudly when an image has no entry or several entries, so a typo in `version` can't break a release with a confusing tag error or skip it silently. Both files are root-level build tooling, so the architect owns this work (no specialist split).

## Context

Commit `61b84ac` (PR #216) replaced `circleci_python_37=0.2.2` under `# Circleci` in `version` with a second `python_37=0.2.2`. `image_version()` (`bin/image.sh`) runs `grep "^${image}=" version | sed ...`, which gives these results:

- `circleci_python_37` → empty string → `docker buildx build ... -t darthjee/circleci_python_37:` → `invalid reference format`.
- `python_37` → `0.2.2\n0.2.2` → the `skip_if_unchanged` pathspec matches nothing → `git diff --quiet` succeeds → `exit 0` without a release.

`image_version` is called through command substitution in `skip_if_unchanged`, `build`, `push` and `image_test`. In each of them, `local version` is declared on its own line, so `version=$(image_version ...)` keeps the function's return status.

## Implementation Steps

### Step 1 — Restore the `version` entry

In `version`, under `# Circleci`, change the line `python_37=0.2.2` (the one right after `circleci_python=0.1.0`) to `circleci_python_37=0.2.2`. Leave the `python_37=0.2.2` line under `# Development` as it is.

### Step 2 — Validate `image_version()` and propagate failures

Rewrite `image_version()` in `bin/image.sh` so that it:

1. Collects the matching lines (`grep "^${image}=" version`).
2. Counts them. With 0 matches, it prints `ERROR: no entry for <image> in version` to stderr and returns 1. With more than 1, it prints `ERROR: <image> has <n> entries in version` to stderr and returns 1.
3. Otherwise, prints the version (the value after `<image>=`), as it does today.

Then make every caller stop on failure: `version=$(image_version "$image") || exit 1` in `skip_if_unchanged`, `build`, `push` and `image_test`. `push`, `description` (through `skip_if_unchanged`) and the rest all run as functions in the main shell, so `exit 1` ends the script with a non-zero code even though the `push`/`description` case branches have no `|| exit 1`. `skip_if_unchanged` already uses `exit 0` for the skip path, so `exit 1` fits the same style.

Update the `bin/image.sh` actions table in `docs/agents/architecture.md` (the "Release Pipeline" section) with one short sentence: every action fails with an error when the image has no entry, or more than one entry, in `version`.

## Files to Change

- `version` — restore `circleci_python_37=0.2.2` under `# Circleci`.
- `bin/image.sh` — validate the match count in `image_version()`; add `|| exit 1` at each call site.
- `docs/agents/architecture.md` — document the new failure behavior of `bin/image.sh`.

## Verification

- `grep -c '^python_37=' version` → `1`. `grep '^circleci_python_37=' version` → `circleci_python_37=0.2.2`.
- `bash -c 'source <(sed -n "/^function image_version/,/^}/p" bin/image.sh); image_version circleci_python_37; image_version python_37'` → `0.2.2` twice.
- Copy `version`, add a duplicate line or remove one, and check that `bin/image.sh push <image>` (with `DOCKER_ID_USER` set, no Docker login needed since it fails first) exits non-zero with the error message, and that `bin/image.sh build <unknown_image>` does the same. Restore `version` afterwards.
- `bash -n bin/image.sh` (syntax check). Also run `shellcheck bin/image.sh` if it's available.

## CI Checks

- No CI job runs on branches (the `release` workflow only runs on tags), so the checks above are local only. The real proof is the next release tag: `release-circleci_python_37` and `release-python_37` both push.

## Notes

- `bin/push_description.sh` (`VERSION=$(cat version | grep ...)`) and `bin/archive.sh` (`current_version`) have their own copies of the lookup. The issue keeps them out of scope. Mention them in the PR as a possible follow-up, but don't change them.
- `python_37` and `circleci_python_37` are deprecated but still published, so they must keep releasing until they're archived.
- Releasing the fix: the `version` file is not under `<image>/<version>/`, so `skip_if_unchanged` decides only on folder changes. Neither image folder changed since the previous tag, so the next tag would **skip** both pushes. The `python_37` release was already silently skipped, and `circleci_python_37` was never built. Check whether the last good release of both images is on Docker Hub. If it isn't, run `bin/image.sh push` by hand after the fix, or add a trivial change to each image folder. Point this out in the PR so the owner can decide.
