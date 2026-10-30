# Plan: Add README.md for darthjee/taap

Issue: #168 — see [docs/agents/issues/168-add-readme-md-for-darthjee-taap.md](../../issues/168-add-readme-md-for-darthjee-taap.md).

## Overview

Add `taap/1.4.2/README.md`, the Docker Hub description of `darthjee/taap`, following [`docs/agents/image-readme.md`](../../image-readme.md). It describes what the published image really ships: `gnuplot` on top of `darthjee/taa`. The `danica`/`gnuplot` gems from `home/Gemfile` are not in the image (#197) and are not listed.

Single-agent plan:

| Agent | File | Scope |
|-------|------|-------|
| `ruby-node` | [ruby-node.md](ruby-node.md) | Write `taap/1.4.2/README.md` |

No version bump, no `init`, no build or test; pushing the description is #171.
