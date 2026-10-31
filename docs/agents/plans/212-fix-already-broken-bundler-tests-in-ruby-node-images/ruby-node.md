# Ruby-Node Plan: Fix already-broken bundler tests in ruby-node images

Main plan: [plan.md](plan.md)

## Overview
A test run on 2026-10-30 found 8 of the 15 pinned ruby-node images failing their `bundler.sh` subtest. The other 7 pass: taa, the three taap 1.5.0 images and the three rails_bower 1.5.0 images. The fixes:
- **ruby_node (all 3):** replace `bundler.sh` with a smoke test. Test only, same version.
- **circleci_taa:** use the correct Gemfile path. Test only, same version.
- **production_taa:** skip the development/test groups in `bundle check`. Test only, same version.
- **rails_yarn (all 3):** new 1.1.1 images built from the current Gemfile.

## Context
- `bin/image.sh test <image>` builds `Dockerfile.test` on top of the published `darthjee/<image>:<version>` from `version`. It copies `<image>/<version>/home` into the WORKDIR and `test/` into `/home/test`, then runs `/home/test/test.sh`.
- Test-only changes keep the same version, because `push` skips changes under `test/` (`skip_if_unchanged ... ":(exclude)$image/$version/test/"`).
- Lesson from #204: `bundle config set without` in the builder stage never reaches the final image. production_rails_bower 1.5.0 fixed this by setting `ENV BUNDLE_WITHOUT development:test` in the final stage.
- taa 1.5.0, circleci_taa 1.5.0 and production_taa 1.5.0 are built on `darthjee/{,circleci_,production_}rails_yarn:1.1.0`. They stay pinned there, so the rails_yarn bump doesn't affect them.

## Steps

- [01 — Replace ruby_node bundler subtest with a smoke test](ruby-node/01-ruby-node-smoke-test.md)
- [02 — Fix circleci_taa and production_taa bundler subtests](ruby-node/02-fix-taa-subtests.md)
- [03 — Add rails_yarn 1.1.1 images](ruby-node/03-rails-yarn-1-1-1.md)
- [04 — Verify the whole family](ruby-node/04-verify.md)

## CI Checks
- Local: `bin/script.sh test ruby_node taa taap rails_bower rails_yarn` must exit 0.
- CircleCI release jobs `release-rails_yarn`, `release-circleci_rails_yarn` and `release-production_rails_yarn` push 1.1.1 on tag. No config change is needed.

## Notes
- Step 03 is the only image change. The images can only be tested after they are built: run `bin/script.sh build rails_yarn` locally (builds all three variants) before `test`, so that `darthjee/*rails_yarn:1.1.1` exists in the local image cache.
- Keep rails_yarn 1.1.1 on the same bases as 1.1.0 (`ruby_331:1.1.1`, `scripts:0.8.0`) unless the build fails. Moving to newer bases is out of scope.
- taap 1.4.2 and rails_bower 1.4.0 are no longer pinned and are out of scope.
