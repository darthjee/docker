# Plan: Push READMEs as Docker Hub descriptions from the CircleCI release job

Issue: [171-push-readmes-as-docker-hub-descriptions-from-the-circleci-release-job.md](../../issues/171-push-readmes-as-docker-hub-descriptions-from-the-circleci-release-job.md)

## Overview

Add a per-image "push description" step to the CircleCI `release` job, make the description push safe to run unattended (warn on a missing README, fail on API errors), and stop README-only changes from re-pushing images. Every file involved (`bin/`, `.circleci/config.yml`, `AGENTS.md`, `docs/agents/`) is owned by the `architect`; no specialist agent has work.

## Context

- The `release` job (`.circleci/config.yml`) runs once per image on every tag and only calls `bin/image.sh push <image>`.
- `bin/image.sh`'s `skip_if_unchanged` exits 0 when `<image>/<version>/` has no diff since the previous tag (second-newest tag by creation date). It counts every file, `README.md` included.
- `bin/push_description.sh` is only sourced by `bin/script.sh`. `push_description_images` fans out to the `circleci_`/`production_` counterparts, `push_description_image` does `exit 1` on a missing README, and `curl` ignores the HTTP status.
- `bin/docker_login.sh` stores whatever `jq -r .token` prints, which is `null` when the login fails.
- Today `ruby_base/0.2.2` and `production_taap/1.4.2` have no README.

Decisions from the issue:

- The description step respects `skip_if_unchanged`, diffing the whole `<image>/<version>/` folder (README included).
- The image push ignores `README.md` in that diff.
- A missing README warns and exits 0; a failed login or a non-2xx PATCH fails the job.
- `bin/script.sh push_description <images>` keeps working.

## Steps

- [01 — Let skip_if_unchanged exclude README.md for the image push](plan/01-skip-if-unchanged-excludes.md)
- [02 — Harden the description push](plan/02-harden-description-push.md)
- [03 — Add a single-image description action](plan/03-single-image-description-action.md)
- [04 — Add the step to the CircleCI release job](plan/04-circleci-release-step.md)
- [05 — Update the docs](plan/05-update-docs.md)

## CI Checks

- No automated tests cover `bin/`. Run `bash -n bin/image.sh bin/push_description.sh bin/docker_login.sh bin/script.sh`.
- Run `bin/image.sh description ruby_base` locally: it must log a warning about the missing README (or the unchanged skip) and exit 0 without needing credentials.
- Validate the CircleCI config with `circleci config validate` if the CLI is available.

## Notes

- Do not change the `scripts` image's `docker_hub.sh`.
- The `release` job uses `machine: true`; CircleCI's Ubuntu machine images ship `curl` and `jq`, which the login needs.
- Because the description step respects `skip_if_unchanged`, READMEs merged before the latest tag are not pushed by CI until their folder changes again. They are published once by hand with `bin/script.sh push_description <images>`.
- No image version bump: only root-level tooling changes.
