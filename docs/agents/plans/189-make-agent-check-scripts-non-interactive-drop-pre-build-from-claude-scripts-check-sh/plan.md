# Plan: Make agent check scripts non-interactive (drop pre_build from .claude/scripts/check_*.sh)

Issue: [189-make-agent-check-scripts-non-interactive-drop-pre-build-from-claude-scripts-check-sh.md](../../issues/189-make-agent-check-scripts-non-interactive-drop-pre-build-from-claude-scripts-check-sh.md)

## Overview

Rewrite the five agent check scripts in `.claude/scripts/` so they run unattended. Each one drops the interactive `pre_build` step, defaults `DOCKER_ID_USER` to `darthjee`, and lists only base project names. This is root-level build tooling, so it is owned by `architect` and no image specialist is involved.

## Context

- `bin/pre_build.sh` runs `docker run -it --rm ... $BASE /bin/bash`. It needs a TTY and waits for input forever, so automated checks fail or hang.
- `bin/image.sh` uses `$DOCKER_ID_USER` for build tags and for `Dockerfile.test`'s `FROM $DOCKER_ID_USER/$IMAGE:$VERSION`. Arcanum's `run_checks.sh` forwards only `HOME`, so the variable is empty inside the checks.
- `bin/script.sh build|test <project>` (`bin/build.sh` `build_images`, `bin/test.sh` `test_images`) already loops over `""`, `circleci_` and `production_` prefixes and skips missing directories. Listing `circleci_*` and `production_*` names in the check scripts builds them twice and quietly skips names like `circleci_circleci_python_37`.

## Implementation Steps

### Step 1 — Rewrite the check scripts

Make every script follow this shape (the `for` list varies per script):

```bash
#!/usr/bin/env bash
set -euo pipefail
set -x

export DOCKER_ID_USER="${DOCKER_ID_USER:-darthjee}"

for image in <base projects>; do
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
```

Base project lists:

| Script | `for image in ...` |
|---|---|
| `check_python.sh` | `python_37 django` |
| `check_ruby.sh` | `ruby_331 rails_gems` |
| `check_node.sh` | `node node_mongo` |
| `check_ruby-node.sh` | `ruby_node rails_bower rails_yarn taa taap` |
| `check_shell.sh` | no loop; keep `bin/script.sh build scripts` / `bin/script.sh test scripts` and add the `export` line |

These lists cover every image currently listed. For example, `ruby_331` expands to `ruby_331`, `circleci_ruby_331` and `production_ruby_331`, and `rails_gems` expands to `rails_gems` and `circleci_rails_gems` because `production_rails_gems` doesn't exist and is skipped.

### Step 2 — Verify

- `grep -n pre_build .claude/scripts/*.sh` returns nothing.
- `bash -n .claude/scripts/check_*.sh` passes.
- Run `bash .claude/scripts/check_shell.sh < /dev/null` (no TTY) and confirm it exits on its own and `docker ps` shows no leftover container. If it fails only because a base image can't be pulled or built locally (for example amd64 on arm64), record that in the PR. It is not a reason to change this plan.

## Files to Change

- `.claude/scripts/check_python.sh`: remove `pre_build`, add the `DOCKER_ID_USER` default, use the base list.
- `.claude/scripts/check_ruby.sh`: same.
- `.claude/scripts/check_node.sh`: same.
- `.claude/scripts/check_ruby-node.sh`: same, and collapse the multi-line list to one line.
- `.claude/scripts/check_shell.sh`: remove `pre_build` and add the `DOCKER_ID_USER` default.

## Notes

- Out of scope: `bin/pre_build.sh` stays interactive for manual use (`docs/agents/contributing.md`), and `bin/image.sh`, `bin/script.sh` and arcanum's `run_checks.sh` are unchanged.
- Builds still default to `PLATFORM=linux/amd64` (`bin/image.sh`), which is slow under emulation on arm64 hosts. That is not addressed here.
