# Issue: taap 2.0.0: rebase onto new taa and bump dependencies

## Description

`taap` (`1.7.0`, with `circleci_` and `production_` counterparts) is built on `taa:1.7.0` and adds gnuplot (apt package plus the `danica` and `gnuplot` gems). Part of epic #256.

**Depends on issues:** #257, #262 (merged; the `taa:2.0.0` images must be published or built locally before building taap).

## Problem

taap 1.7.0 still sits on `taa:1.7.0` (Ruby 3.3.1, `scripts:0.11.0`) while `taa` is now at `2.0.0` (Ruby 3.4.12, Node 24, `scripts:0.15.0`). Its Gemfile pins the old shared gem versions, so it would duplicate or downgrade gems relative to the new base.

## Expected Behavior

- New version `2.0.0` (a major bump, because the inherited Ruby runtime changes) of `taap`, `circleci_taap` and `production_taap`, built on `linux/amd64` and `linux/arm64`, with all existing subtests passing.
- No duplicated gems in the final images. The bundle layer holds only taap's own gems (`danica`, `gnuplot`).

## Solution

- Create `2.0.0` for all three images with `bin/script.sh init <image> 2.0.0`, and update the `version` file.
- **Dockerfiles:**
  - Use `FROM darthjee/scripts:0.15.0 AS scripts` and `FROM darthjee/{,circleci_,production_}taa:2.0.0 AS base`.
  - **Hardening (as in #262):**
    - Use uppercase `AS`.
    - Write `ENV K=V` instead of `ENV K V`.
    - Drop `RUN bundle config set without 'development test'` from production, because `BUNDLE_WITHOUT=development:test` is already inherited from production_rails_yarn/production_taa 2.0.0.
  - **gnuplot apt install:** use `apt-get install -y --no-install-recommends gnuplot-nox` in place of `gnuplot`. This gives a smaller image without X11/Qt; `gnuplot --version` still works.
- **Gemfile / Gemfile.lock (identical in all three variants):**
  - Copy taa 2.0.0's Gemfile exactly: `ruby '3.4.12'`, bundler `>= 4.0.24`, and every shared gem at taa 2.0.0's version.
  - Add the taap-only gems `danica 3.0.0` and `gnuplot 2.6.2`, which are already the latest.
  - Seed Gemfile.lock from taa 2.0.0's lock so that transitive gems match the base. The general rule is documented in #274.
- **Tests:** keep the existing subtests and add no new ones:
  - all variants: bundler, gems, gnuplot
  - circleci only: user, yarn_cache
- **READMEs:** update each 2.0.0 `README.md` per `docs/agents/image-readme.md` (Ruby 3.4.12, Node 24, taa 2.0.0 base).
- **Verification:**
  - Build any missing parents locally (ruby_node, rails_yarn and taa 2.0.0 with their variants; scripts 0.15.0 and ruby_3412 are published).
  - Then run `bin/script.sh test` for every touched image on amd64 and arm64.
  - Spot-check that no shared gem is duplicated.
- No CI wiring change is expected.

## Benefits

- taap moves onto Ruby 3.4.12 and Node 24, consistent with the rest of the ruby-node chain.
- Smaller images, from the deduplicated gems and the gnuplot-nox switch.
