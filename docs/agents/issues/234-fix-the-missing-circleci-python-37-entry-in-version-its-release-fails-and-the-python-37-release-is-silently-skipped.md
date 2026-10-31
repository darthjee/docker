# Issue: Fix the missing `circleci_python_37` entry in `version` (its release fails and the `python_37` release is silently skipped)

## Description

The `release-circleci_python_37` CI job fails in its **Release** step before anything is built:

```
ERROR: failed to build: invalid tag "********/circleci_python_37:": invalid reference format
```

### Root cause

Commit `61b84ac` (Fix #184, PR #216) changed the `version` file. In the `# Circleci` section it replaced `circleci_python_37=0.2.2` with `python_37=0.2.2`, when it should have kept the line next to the new `circleci_python=0.1.0` line.

`image_version()` in `bin/image.sh` runs `grep "^${image}="` on `version`. That causes two problems:

- **`circleci_python_37`**: grep finds no line, so the version is empty. The tag becomes `circleci_python_37:`, which is invalid, so `docker buildx build` fails before it starts. This is the error in the CI log.
- **`python_37`**: grep finds two lines, so the version is `0.2.2\n0.2.2`. The pathspec `skip_if_unchanged` builds from it matches nothing, so `git diff --quiet` succeeds. The job then exits 0 without releasing anything. Nothing reports the failure.

## Expected Behavior

- `image_version circleci_python_37` and `image_version python_37` each print `0.2.2` (one line).
- `grep -c '^python_37=' version` returns `1`.
- `bin/image.sh push <unknown_image>`, and the same for an image listed twice, fails with a clear message and a non-zero exit code.
- On the next release tag, `release-circleci_python_37` and `release-python_37` both build and push their images.

Scope:

- In scope: the `version` entry fix and the `image_version()` check (both in this issue, one PR).
- Out of scope: any other change to the release flow, the `python_37` / `circleci_python_37` Dockerfiles, or their READMEs.

## Solution

1. In `version`, under `# Circleci`, change the duplicate `python_37=0.2.2` back to `circleci_python_37=0.2.2`.
2. Make `image_version()` in `bin/image.sh` return 1 and print a clear message to stderr when an image has zero entries or more than one entry in `version`. A typo like this one would then fail clearly, not with a confusing error or a silent skip.
   - `image_version` runs inside `$(...)` in its callers (`skip_if_unchanged`, `build`, `push`, `image_test`), so an `exit` in it would only leave the subshell. Each caller has to check the result, e.g. `version=$(image_version "$image") || exit 1`. `local version` is already declared on its own line, so the exit status is kept.
   - The `push` and `description` case branches have no `|| exit 1`. They run in the main shell, though, so an `exit 1` inside those functions still ends the script with a non-zero code. Confirm that the CI Release and Push description steps fail.

## Benefits

- `circleci_python_37` and `python_37` are released again.
- A missing or duplicate entry in `version` now stops the release with a clear error, so it can no longer fail with a confusing tag error or skip without saying so.
