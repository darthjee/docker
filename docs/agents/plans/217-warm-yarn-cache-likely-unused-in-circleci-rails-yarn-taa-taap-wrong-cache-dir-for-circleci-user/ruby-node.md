# Ruby-Node Plan: Warm yarn cache unused in circleci_rails_yarn/taa/taap (wrong cache dir for circleci user)

Main plan: [plan.md](plan.md)

## Overview
`circleci_rails_yarn/1.1.0` and `circleci_taa/1.5.0` copy their warm yarn cache to `/usr/local/share/.cache/yarn/v6/`, but the images run as `circleci`, whose `yarn cache dir` is `/home/circleci/.cache/yarn/v6` (verified: empty in the published image). The current unpublished versions (`circleci_rails_yarn:1.2.0`, `circleci_taa:1.6.0`, `circleci_taap:1.5.0`, none on Docker Hub yet) are fixed in place to move the cache to the `circleci` user's dir, following the `circleci_node/0.2.3` fix from #178, and rebuilt in a chain: `circleci_rails_yarn:1.2.0` → `circleci_taa:1.6.0` → `circleci_taap:1.5.0`.

## Context
- `yarn_builder.sh` (`scripts/0.11.0`, the same as in 0.8.0/0.10.0) runs as root. It installs into the root cache `/usr/local/share/.cache/yarn/v6`, seeds a dedupe list from what is already in that root cache, and writes only new packages to `/home/circleci/yarn/new/`.
- `circleci_node/0.2.3` is the reference: it creates and `chown`s `/home/circleci/.cache/yarn` in the base stage, copies the cache with `COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /home/circleci/.cache/yarn/v6/`, and tests it in `test/subtests/yarn_cache.sh` and `test/subtests/user.sh`.
- No `bin/script.sh init` is needed: the target versions are unpublished, so they are fixed in place and `version` stays unchanged.

## Steps

- [01 — Fix circleci_rails_yarn 1.2.0](ruby-node/01-circleci-rails-yarn.md)
- [02 — Fix circleci_taa 1.6.0](ruby-node/02-circleci-taa.md)
- [03 — Fix circleci_taap 1.5.0](ruby-node/03-circleci-taap.md)

## CI Checks
- `bin/image.sh build <image>` followed by `bin/image.sh test <image>` for each of `circleci_rails_yarn`, `circleci_taa`, `circleci_taap`, in that order (each builds on the previous one). Release jobs `release-circleci_rails_yarn`, `release-circleci_taa` and `release-circleci_taap` in `.circleci/config.yml` run on tags only, and their dependency order is already correct.

## Notes
- Building locally on arm64 hosts may need `--platform linux/amd64`, depending on whether the bases are multi-arch.
- `production_*` and the non-CircleCI `rails_yarn`/`taa`/`taap` images are out of scope. They run as other users, and their cache paths were not part of this issue.
- Published versions (`circleci_rails_yarn` `1.1.0`, `circleci_taa` `1.5.0`, `circleci_taap` `1.4.2`) and the unpublished intermediate `circleci_rails_yarn/1.1.1` stay untouched.
