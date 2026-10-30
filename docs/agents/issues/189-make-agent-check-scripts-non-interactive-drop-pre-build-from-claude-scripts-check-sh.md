# Issue: Make agent check scripts non-interactive (drop pre_build from .claude/scripts/check_*.sh)

## Description
Make the agent check scripts in `.claude/scripts/check_*.sh` run unattended: drop the interactive `pre_build` step, give `DOCKER_ID_USER` a default, and stop building/testing the `circleci_`/`production_` variants twice.

## Problem
All five agent check scripts (`check_python.sh`, `check_ruby.sh`, `check_ruby-node.sh`, `check_node.sh`, `check_shell.sh`) run, for each image:

```bash
bin/script.sh pre_build "$image"
bin/script.sh build "$image"
bin/script.sh test "$image"
```

This broke the checks while resolving #162 (PR #188) in three ways:

1. **Interactive `pre_build`.** `bin/pre_build.sh` runs `docker run -it --rm ... $BASE /bin/bash`. Without a TTY it fails with `the input device is not a TTY`. With a fake TTY (`script -q /dev/null ...`), the shell waits for input and the check hangs, leaving a `python:3.7.2 /bin/bash` container running.
2. **Empty `DOCKER_ID_USER`.** `bin/image.sh` uses `$DOCKER_ID_USER` for the `build` tags and for `test` (`Dockerfile.test`: `FROM $DOCKER_ID_USER/$IMAGE:$VERSION`). The checks run through arcanum's `run_checks.sh`, which only forwards `HOME`, so the variable is empty and Docker rejects `/circleci_python_37:0.2.2` with `invalid reference format`.
3. **Duplicated variants.** `bin/script.sh build|test <project>` already loops over `<project>`, `circleci_<project>` and `production_<project>`. The check scripts also list the `circleci_`/`production_` names, so those images are built and tested twice, and names like `circleci_circleci_python_37` are silently skipped.

## Expected Behavior
- Every `.claude/scripts/check_*.sh` runs to completion without a TTY and leaves no container behind.
- `build`/`test` resolve images as `darthjee/<image>:<version>` even when `DOCKER_ID_USER` is not passed through, while still honoring it when it is set.
- Each image variant is built and tested once per check run.

## Solution
In each of `check_python.sh`, `check_ruby.sh`, `check_ruby-node.sh`, `check_node.sh` and `check_shell.sh`:

- Remove the `bin/script.sh pre_build ...` call. Keep `build` and `test`.
- Add `export DOCKER_ID_USER="${DOCKER_ID_USER:-darthjee}"` near the top, after `set -euo pipefail`.
- Trim the image list to base project names only, since `bin/script.sh` expands the `circleci_`/`production_` variants itself:
  - `check_python.sh`: `python_37 django`
  - `check_ruby.sh`: `ruby_331 rails_gems`
  - `check_node.sh`: `node node_mongo`
  - `check_ruby-node.sh`: `ruby_node rails_bower rails_yarn taa taap`
  - `check_shell.sh`: `scripts` (already a base name)

Out of scope:

- `bin/pre_build.sh` stays interactive for manual use (documented in `docs/agents/contributing.md`).
- `bin/image.sh`, `bin/script.sh` and arcanum's `run_checks.sh` are not changed.

### Acceptance criteria

- [ ] No `.claude/scripts/check_*.sh` calls `pre_build`.
- [ ] Each check script exports `DOCKER_ID_USER` with a `darthjee` default.
- [ ] Each check script lists only base project names.
- [ ] Each check script runs to completion without a TTY (e.g. `bash .claude/scripts/check_shell.sh < /dev/null`).
- [ ] `bin/pre_build.sh` and its docs are unchanged.

## Benefits
- Automated pipelines (`auto-fix-issue`, `auto-resolve-issue`) can run real checks instead of failing or hanging.
- No orphaned containers after agent runs.
- Check runs build each image once, so they are roughly twice as fast.
