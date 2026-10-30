# Architect Plan: Make bin/script.sh build and test exit non-zero on failure

Main plan: [plan.md](plan.md)

## Shared contracts

Produces the test entry point, release exclusion and `Dockerfile.test` behaviour described in [plan.md](plan.md#shared-contracts). Opens the follow-up issues for broken tests reported by the specialists.

## Steps

- [01 — Fail fast in bin/build.sh](architect/01-fail-fast-build.md)
- [02 — Check docker build in bin/image.sh build](architect/02-image-build-status.md)
- [03 — Single test path in bin/image.sh test](architect/03-image-test-single-path.md)
- [04 — Exclude test/ from the release skip check](architect/04-release-skip-test.md)
- [05 — Update docs and open follow-up issues](architect/05-docs-and-follow-ups.md)

## Notes
- Do steps 01–04 before the specialists start, so they can run `bin/script.sh test` with the new runner.
- `bin/script.sh` calls `build`/`testy` as the last command in the `case`, so the script's exit status already follows their return value. No change needed there.
- `fetch_bases` falls back to `$0 build $BUILDABLE`, which re-enters `bin/script.sh build`. With fail-fast, a failed fallback now returns non-zero all the way up.
- No CI job runs `build`/`test` (CI only runs `bin/image.sh push`/`description`). Check locally with `bash -n bin/*.sh` and by running `bin/script.sh build`/`test` against a deliberately broken case.
