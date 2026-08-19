# Plan: Modernize multi-arch image builds to docker buildx instead of QEMU + per-arch docker build

Issue: [139-modernize-multi-arch-image-builds-to-docker-buildx-instead-of-qemu---per-arch-docker-build.md](../../issues/139-modernize-multi-arch-image-builds-to-docker-buildx-instead-of-qemu---per-arch-docker-build.md)

## Overview

Replace this repo's QEMU-binfmt + per-arch `docker build --platform` release pattern with a single
`docker buildx build --platform linux/amd64,linux/arm64 --push` invocation per image, producing one
multi-platform manifest under one tag instead of today's `:<version>` / `:<version>-arm64` pair. This collapses
each image's two CircleCI jobs (`release-<image>` / `release-<image>-arm64`) into one, and is purely a
root-level build-tooling change — no per-image Dockerfile content changes are needed, so there is no specialist
agent split; this is entirely `bin/image.sh` and `.circleci/config.yml` work.

## Context

- Today: `bin/image.sh`'s `build()`/`push()` take an optional `arch` argument and run a fully separate
  `docker build --platform linux/$arch ...` per arch, pushing arch-suffixed tags independently — no atomicity
  across the two, and (per the issue's Backward compatibility section) chained internal `FROM`s referencing an
  unsuffixed parent tag may currently resolve to the wrong arch on the arm64 leg.
- `.circleci/config.yml`'s `release` job template runs "Set up QEMU" (`tonistiigi/binfmt --install all`) then
  `bin/image.sh push <image> [arch]` on a `machine: true` executor. Every image in `version` already has both
  an amd64 and an arm64 job today (~32 image/arch job pairs), each with independent `requires:` chains.
- `circleci/docker` orb adoption is explicitly deferred (see the issue) — this plan only covers the buildx
  migration.
- Rollout is scoped to this repo (majora and oak are separate follow-ups; oak's is already opened as
  darthjee/oak#243).

## Implementation Steps

### Step 1 — Prototype and validate the buildx approach

Manually validate `docker buildx build --platform linux/amd64,linux/arm64 --push` against one image (`scripts`
is the natural first candidate — it's the shared dependency every other image builds `FROM`) before touching
the shared CI job template:

- Confirm `docker buildx create --use` bootstraps a working builder on the same `machine: true` executor image
  CircleCI uses (or locally in an equivalent environment) — the default `docker` driver can't do a
  multi-platform `--push`, so this bootstrap step is required, not optional.
- Confirm the QEMU "Set up QEMU" step is still required alongside buildx (cross-building arm64 on an amd64 host
  doesn't stop needing emulation just because buildx is doing the invocation).
- Push the prototype under a scratch/test tag and confirm both `amd64` and `arm64` resolve correctly from that
  one tag via `docker buildx imagetools inspect <tag>` (or by pulling on both a real amd64 and arm64 host).

### Step 2 — Rewrite `bin/image.sh`'s push path

- Add a new buildx-based push function (no `arch` argument) that runs the single multi-platform
  `docker buildx build --platform linux/amd64,linux/arm64 -f "$image/$version/Dockerfile" "$image/$version/" -t "$DOCKER_ID_USER/$image:$version" -t "$DOCKER_ID_USER/$image:latest" --push` invocation, replacing today's per-arch `build()`/`push()` pair for the CI-facing `push` action.
- Keep the existing single-arch `build()`/`tag()` functions as-is — they remain the local single-platform debug
  path (per the issue's decision), just no longer used by the CI `push` action.
- Keep `image_version`, `skip_if_unchanged`, and `image_test` unchanged in behavior; wire `skip_if_unchanged`
  to run once (it already only needs to run once now that there's a single job per image, removing the
  redundant double-evaluation that existed when two jobs both called `push`).
- Drop the `arch` positional argument from the `push` CLI action's signature (the `ACTION`/`case` dispatch at
  the bottom of the script) — the CI path never passes one anymore. `build`/`tag` keep their existing `arch`
  argument for local debug use.

### Step 3 — Collapse `.circleci/config.yml`'s job topology

- In the shared `release` job template: remove the `arch` parameter (or leave it unused/dead — judgment call
  during implementation, but prefer removing it since nothing sets it anymore), add a "Set up buildx" step
  (`docker buildx create --use`) after "Set up QEMU" and before the release step, and change the release step
  to call `bin/image.sh push <image>` (no arch arg).
- Remove every `release-<image>-arm64` job invocation and its `arch: arm64` parameter from the `workflows`
  section, and re-point any `requires:` that referenced a `-arm64` job name at the corresponding non-suffixed
  job instead (e.g. `release-rails_yarn` now just requires `release-scripts`, not
  `[release-scripts, release-scripts-arm64]` style duplication — check each chain individually, since some
  already require multiple non-arm64 jobs).
- This roughly halves the workflow's job count (today: ~32 image jobs × 2 arch variants each) and removes the
  duplicated `-arm64` blocks.

### Step 4 — Roll out across all images and re-verify manifest correctness

- Apply Step 3's collapsed template to every image currently in `version` (not just the Step 1 prototype).
- Re-run the manifest-correctness check from Step 1 against at least one **chained** image (e.g. `rails_gems`,
  which builds `FROM darthjee/ruby_331:<version>`) in addition to a leaf image — this specifically confirms
  whether the possible existing arch-resolution bug flagged in the issue's Backward compatibility section is
  real, and that buildx's unified manifest fixes it going forward.

### Step 5 — Minor cleanup: `bin/archive.sh`

- `remove_from_circleci()` in `bin/archive.sh` currently strips both `release-{image}` and
  `release-{image}-arm64` name markers when an image is retired entirely. Once the `-arm64` job variants are
  gone (Step 3), the second check becomes permanently dead (harmless, but stale) — remove it as part of this
  change for cleanliness, not because leaving it causes a bug.

## Files to Change

- `bin/image.sh` — new buildx-based push function; `push` CLI action drops its `arch` argument; `build`/`tag`
  keep theirs unchanged.
- `.circleci/config.yml` — `release` job template gets a buildx bootstrap step and drops the `arch` parameter;
  every `-arm64` job invocation and its `requires:`/`arch:` entries are removed from the `workflows` section.
- `bin/archive.sh` — drop the now-dead `-arm64` marker check in `remove_from_circleci()` (minor cleanup).

## CI Checks

No local command runs `.circleci/config.yml` itself end-to-end (there's no `circleci-cli`/`yamllint` wired into
this repo today). Validate manually:
- `circleci config validate` (or equivalent) against the edited YAML for basic syntax correctness, if the CLI
  is available in the implementing environment.
- Actually exercising the new `bin/image.sh` push path against a real (scratch/test) Docker Hub namespace is
  the only real way to confirm the buildx invocation and manifest correctness — this can't be simulated purely
  locally without Docker Hub credentials and a multi-arch-capable builder.

## Notes

- `circleci/docker` orb adoption is explicitly out of scope for this plan (see the issue's orb decision).
- majora and oak rollouts are separate follow-up issues, not part of this plan (oak's already opened as
  darthjee/oak#243).
- Whether the CircleCI `machine` executor's default image already ships the `docker buildx` CLI plugin is
  unverified — Step 1's prototype is where this gets confirmed; if it's missing, an install step needs to be
  added to the "Set up buildx" step.
- The possible existing arch-resolution bug for chained `FROM`s (Backward compatibility, in the issue) is
  unverified against a real build — Step 4 is where it actually gets confirmed one way or the other.
