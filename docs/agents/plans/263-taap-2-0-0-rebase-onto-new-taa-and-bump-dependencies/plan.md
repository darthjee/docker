# Plan: taap 2.0.0: rebase onto new taa and bump dependencies

Issue: [263-taap-2-0-0-rebase-onto-new-taa-and-bump-dependencies.md](../../issues/263-taap-2-0-0-rebase-onto-new-taa-and-bump-dependencies.md)

## Overview
Create `taap`, `circleci_taap` and `production_taap` 2.0.0 on top of `{,circleci_,production_}taa:2.0.0` and `scripts:0.15.0`. The Gemfile/lock is aligned with `taa 2.0.0` (Ruby 3.4.12) plus `danica`/`gnuplot`. The Dockerfiles get the #262 hardening, and the apt package switches to `gnuplot-nox` with `--no-install-recommends`. All work belongs to the `ruby-node` agent.

See [ruby-node.md](ruby-node.md) for the full plan.
