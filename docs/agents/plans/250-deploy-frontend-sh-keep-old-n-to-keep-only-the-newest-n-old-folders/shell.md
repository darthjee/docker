# Shell Plan: deploy_frontend.sh: KEEP_OLD=<n> to keep only the newest N _old_* folders

Main plan: [plan.md](plan.md)

## Shared contracts

You produce the behaviour described in the `KEEP_OLD` table in [plan.md](plan.md#shared-contracts): values, `_old_<digits>`-only matching, numeric ordering, the `Removed old folder: <full path>` output line, the failure before any remote call for invalid values, and version `0.14.0`.

## Steps

- [01 — Create scripts 0.14.0](shell/01-create-version.md)
- [02 — Implement KEEP_OLD=<n> in release](shell/02-implement-keep-old-n.md)
- [03 — Tests](shell/03-tests.md)
- [04 — README](shell/04-readme.md)

## CI Checks
- `scripts`: `bin/script.sh pre_build scripts && bin/script.sh build scripts && bin/script.sh test scripts` (CI job: `release-scripts` workflow build/test of the `scripts` image)

## Notes
- The tests run inside Alpine (`scripts/0.14.0/test/Dockerfile`), and the ssh stub runs the remote command with `sh -c` (BusyBox `ash`) when `SSH_STUB_EXEC` is set. So the real-filesystem tests check BusyBox compatibility for you. Keep the remote snippet POSIX `sh`, with no `head -n -N`, `ls -t`, `find -printf`, `sort -V` or `xargs -r`.
- Paths in the test fixtures contain spaces (`si te`). The remote snippet must survive those, and `'`, in `SSH_REMOTE_DIR`.
