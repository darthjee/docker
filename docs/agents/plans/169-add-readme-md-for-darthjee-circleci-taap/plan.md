# Plan: Add README.md for darthjee/circleci_taap (#169)

Issue: [docs/agents/issues/169-add-readme-md-for-darthjee-circleci-taap.md](../../issues/169-add-readme-md-for-darthjee-circleci-taap.md)

## Overview

Add `circleci_taap/1.4.2/README.md`, the Docker Hub description of `darthjee/circleci_taap`, following [`docs/agents/image-readme.md`](../../image-readme.md). It reuses the wording of `taap/1.4.2/README.md` (#168) and the CircleCI usage layout of `circleci_rails_bower/1.4.0/README.md`. It is a README-only change, made in place: no init, no version bump, no build or test.

## Agents

| Agent | Plan | Work |
|-------|------|------|
| `ruby-node` | [ruby-node.md](ruby-node.md) | Write `circleci_taap/1.4.2/README.md` |

## Order

Single step; no dependencies between agents.

## Out of scope

- The missing `danica`/`gnuplot` gems (#199): the README lists only what the published image ships.
- Pushing the description to Docker Hub (#171).
- Editing `circleci_taa`'s README.
