# Plan: Add README.md for darthjee/production_taap (#170)

Issue: [docs/agents/issues/170-add-readme-md-for-darthjee-production-taap.md](../../issues/170-add-readme-md-for-darthjee-production-taap.md)

## Overview

Add `production_taap/1.4.2/README.md`, the Docker Hub description of `darthjee/production_taap`, following [`docs/agents/image-readme.md`](../../image-readme.md). It reuses the wording of `taap/1.4.2/README.md` (#168) and the production-counterpart paragraph and usage of `production_rails_bower/1.4.0/README.md`. It is a README-only change, made in place: no init, no version bump, no build or test.

## Agents

| Agent | Plan | Work |
|-------|------|------|
| `ruby-node` | [ruby-node.md](ruby-node.md) | Write `production_taap/1.4.2/README.md` |

## Order

Single step; no dependencies between agents.

## Out of scope

- The missing `danica`/`gnuplot` gems (#200): the README lists only what the published image ships.
- Pushing the description to Docker Hub (#171).
- Editing `production_taa`'s README.
