# Issue: Remove the darthjee/fly image

## Description

The `darthjee/fly` image (Concourse CI `fly` CLI v3.14.1 on `alpine:3.9.4`) is no longer used: Concourse is not used anymore. This was originally the `fly` README sub-issue of #153; instead of writing a README for it, the image is removed from the repo entirely.

## Problem

- The image is dead weight: it still has a release job, a `version` entry, docs and agent scope, and is built/tested by `.claude/scripts/check_tools.sh`.
- Its base `alpine:3.9.4` is EOL and its `fly` (v3.14.1, 2018) only ships a `fly_linux_amd64` binary, so any rebuild under the multi-arch `bin/image.sh push` (`linux/amd64,linux/arm64`) would publish a broken `linux/arm64` variant (the reason #174 was opened; #174 is closed as not planned).
- Without a README, it also blocks the #153 goal of every image having a Docker Hub description.

## Expected Behavior

- No `fly` image source, version entry, CI job, documentation or agent scope remains in the repo.
- The `release` workflow keeps working for every other image.
- The `tools` agent covers `heroku` only.

## Solution

Remove every reference to the `fly` image:

| File | Reference |
|---|---|
| `fly/` | the whole image folder (`0.0.1/Dockerfile`) |
| `version` | `fly=0.0.1` |
| `README.md` | the `fly:0.0.1` image list entry |
| `.circleci/config.yml` | the `release-fly` job (no other job `requires` it) — **see the anchor caveat below** |
| `AGENTS.md` | the tool images example (`fly`, `scripts`, `heroku`), the `version` snippet, and the `fly/` folder tree entry |
| `docs/agents/folder-structure.md` | the `fly/` row |
| `.claude/agents/tools.md` | description and `fly/` bullet — the agent now covers `heroku` only |
| `.claude/agents/architect.md` | `fly/` in the `tools` agent's scope |
| `.claude/agents/shell.md` | `fly/` in the "do not touch" list |
| `.claude/scripts/check_tools.sh` | `for image in fly heroku` → `heroku` only |

**CircleCI anchor caveat:** the YAML anchor `filters: &tag_only` is defined on the `release-fly` job, and every other job references it as `filters: *tag_only`. Deleting the job as-is would break the whole `release` workflow. Move the anchor definition (`&tag_only` with its `tags`/`branches` block) to the next job (`release-scripts`), or to a top-level definition, before removing `release-fly`.

After the change, `grep -rnw fly --exclude-dir=.git .` must return no reference to the image (unrelated uses of the word, if any, are fine).

### Out of scope

- Deleting the `darthjee/fly` repository on Docker Hub — existing pulls of `0.0.1` keep working; the owner can delete it manually if desired.
- No README is written for `fly`.

### Responsible agent

`architect` (root-level files, `.circleci/config.yml`, `.claude/` agents and scripts, plus the `fly/` folder).

### Testing

No automated tests. Verify `.circleci/config.yml` is still valid (e.g. `circleci config validate`, if available) and every remaining job still resolves `*tag_only`, `.claude/scripts/check_tools.sh` still runs for `heroku`, and the next release workflow runs without the `release-fly` job.

Parent epic: #153

## Benefits

- Less to maintain: one fewer image, CI job and agent scope.
- Removes an EOL base and a latent broken arm64 build.
- Unblocks #153: no image without a README remains in the tools family besides `heroku`.
