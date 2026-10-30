# Plan: Make bin/script.sh build and test exit non-zero on failure

Issue: [205-make-bin-script-sh-build-and-test-exit-non-zero-on-failure.md](../../issues/205-make-bin-script-sh-build-and-test-exit-non-zero-on-failure.md)

## Overview
Make `bin/script.sh build` stop and exit non-zero on the first failed base fetch or image build, and make `bin/script.sh test` run each image's real `/home/test/test.sh` and pass its status through. The shared `bin/` tooling and docs belong to the architect. The 20 current-version `test/test.sh` copies that use `|| exit 0` are switched to the fail-on-any-subtest pattern by the ruby and ruby-node specialists. Image tests that were already broken get follow-up issues instead of being fixed here.

## Agents involved

- [architect](architect.md) — `bin/build.sh`, `bin/image.sh`, `docs/agents/architecture.md`; goes first
- [ruby](ruby.md) — `ruby_331`, `rails_gems` and variants
- [ruby-node](ruby-node.md) — `ruby_node`, `taa`, `taap`, `rails_bower`, `rails_yarn` and variants

## Shared contracts

- **Test entry point:** `bin/image.sh test <image>` builds the test image from `<image>/<version>/test/Dockerfile` if it exists, otherwise from the root `Dockerfile.test`, then runs `docker-compose run --rm test` (the service's `command: /home/test/test.sh`, no `pwd` override). It returns non-zero if the build fails or `test.sh` exits non-zero. Images without `<image>/<version>/test/` print `no tests for <image>` and return 0.
- **`Dockerfile.test`** copies both `$IMAGE/$VERSION/home` and `$IMAGE/$VERSION/test`. An image with no `home/` folder needs its own `test/Dockerfile`.
- **Release:** `bin/image.sh push` ignores `<image>/<version>/test/` (and `README.md`) when deciding whether to re-push. So editing `test/` in a published version folder is a same-version fix: no `bin/script.sh init`, no version bump.
- **Canonical `test/test.sh`** (copy of `scripts/0.11.0/test/test.sh`, adjusted to the standard `/home/test` location):

  ```bash
  #!/bin/bash

  FAILED=0

  for TEST in /home/test/subtests/*.sh; do
    echo "== $(basename "$TEST")"
    if ! /bin/bash "$TEST"; then
      FAILED=$((FAILED + 1))
    fi
  done

  if [ "$FAILED" -ne 0 ]; then
    echo "$FAILED test file(s) failed"
    exit 1
  fi

  echo "All tests passed"
  ```

- **Broken tests:** a specialist that finds an image whose tests fail with the new runner (and the failure isn't caused by the runner change itself) doesn't fix it. It reports the image name and the failing subtest/output back to the architect, who opens one follow-up issue per image (or one grouped issue) with `spawn_issue.sh`, cross-referenced to #205.
