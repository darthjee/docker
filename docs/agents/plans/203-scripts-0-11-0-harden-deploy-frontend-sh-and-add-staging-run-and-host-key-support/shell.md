# Shell Plan: scripts 0.11.0: harden deploy_frontend.sh and add staging, run and host-key support

Main plan: [plan.md](plan.md)

## Shared contracts

- Provide: `scripts/0.11.0/test/Dockerfile` (built with the repo root as context and build args
  `DOCKER_ID_USER`, `IMAGE`, `VERSION`, `USER_NAME`) whose default command is
  `/home/test/test.sh`; `test.sh` exits non-zero when any subtest fails.
- Rely on: the architect makes `bin/image.sh test scripts` use that Dockerfile and return the
  test's exit status.

## Steps

- [01 — Create the 0.11.0 version](shell/01-create-version.md)
- [02 — Rewrite deploy_frontend.sh](shell/02-rewrite-deploy-frontend.md)
- [03 — Add the test suite](shell/03-add-tests.md)
- [04 — Update the README](shell/04-update-readme.md)

## CI Checks

- `scripts`: `bin/script.sh pre_build scripts`, `bin/script.sh build scripts`,
  `bin/script.sh test scripts` (CI job: `release-scripts` builds and pushes; CI runs no tests).

## Notes

- Only `deploy_frontend.sh` changes among the scripts; the published Dockerfile is unchanged
  (no bash in the image: the script runs in the images that copy it).
- Consumer images keep their pinned `darthjee/scripts` versions; bumping them is out of scope.
- The remote shell may be POSIX `sh`: every string sent over ssh must be valid POSIX sh.
