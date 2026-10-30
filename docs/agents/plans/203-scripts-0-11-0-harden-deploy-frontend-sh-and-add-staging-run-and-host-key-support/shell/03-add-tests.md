# Add the test suite

Add `scripts/0.11.0/test/`:

- `Dockerfile` — `FROM $DOCKER_ID_USER/$IMAGE:$VERSION` (same `ARG`s as the root
  `Dockerfile.test`), `RUN apk add --no-cache bash`, `COPY $IMAGE/$VERSION/test /home/test`,
  default `CMD ["/bin/bash", "/home/test/test.sh"]`. No user/chown (the image has no `app` user).
- `test.sh` — runs every `subtests/*.sh` with bash, counts failures, exits 1 if any failed.
- `stubs/ssh`, `stubs/rsync` — record their arguments (one line per call) to a log file given by
  an env var and exit with a configurable status; tests put `stubs/` first on `PATH`.
- `subtests/` — plain bash files with a tiny assert helper, covering at least:
  - `workspace_temp_dir`/`remote_temp_dir` with and without `CIRCLE_WORKFLOW_WORKSPACE_ID` and
    `DEPLOY_PATH`;
  - unknown and missing action → exit 1 and the action list on stderr;
  - `quote` with spaces and single quotes (round-trip through `sh -c`);
  - commands built by `link` (DEPLOY_PATH form, TARGET form, neither → exit 1), `run`, `upload`
    (with and without `EXCLUDE_FROM`), `release` (with and without `KEEP_OLD`);
  - host-key options with and without `SSH_KNOWN_HOSTS`;
  - a failing stubbed `ssh`/`rsync` makes the action exit non-zero.
- Run the release chain built by the test through a real `sh` against temp folders (first deploy,
  normal swap, missing staging) to check its behavior, not only its text.

Run with `bin/script.sh build scripts && bin/script.sh test scripts` once the architect's harness
change is in.

## Files to Change
- `scripts/0.11.0/test/Dockerfile` — test image (bash added, test only).
- `scripts/0.11.0/test/test.sh` — runner, non-zero on failure.
- `scripts/0.11.0/test/stubs/ssh`, `scripts/0.11.0/test/stubs/rsync` — argument-recording stubs.
- `scripts/0.11.0/test/subtests/*.sh` — the tests.
