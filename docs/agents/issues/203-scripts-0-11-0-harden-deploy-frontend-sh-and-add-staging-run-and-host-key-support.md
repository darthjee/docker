# Issue: scripts 0.11.0: harden deploy_frontend.sh and add staging, run and host-key support

## Description

Target: `scripts/<version>/home/sbin/deploy_frontend.sh` in the `darthjee/scripts` image (latest version is
`0.10.0`, in `scripts/0.10.0/`). Create the new version
folder (e.g. `0.11.0/`) following the repo's versioning convention, with the updated script and
README.

### Why

Pidgey (`darthjee/pidgey`, a PHP 8.4 app) will deploy to a Dreamhost host through this script,
taken from the image instead of a per-project copy. The rsync/SSH staging-and-swap pattern is
the one Oak and majora already use. Their **repo copies** (for example
majora's `bin/deploy_frontend.sh`, identical to Oak's) are ahead of
`0.10.0`, and Pidgey needs a few more things on top of them. Background on how the pattern works is in the Oak/majora deploy notes.

## Problem

1. **No per-workflow staging folder and no `DEPLOY_PATH`.** The Oak/majora copies stage into
   `${SSH_REMOTE_TEMP_DIR%/}-$CIRCLE_WORKFLOW_WORKSPACE_ID` plus an optional `/$DEPLOY_PATH`,
   so parallel CircleCI jobs of one workflow fill the same staging tree. `0.10.0` uses
   `$SSH_REMOTE_TEMP_DIR` as is, for every action.
2. **`link`** is `ln -s $SOURCE $TARGET`: no `-fn`, and the target isn't inside staging. The
   repo copies use `ln -sfn $SOURCE <staging>/$DEPLOY_PATH`.
3. **No way to run a command remotely** inside the staging folder. Pidgey must run its database
   migrations (`$PHP_BIN bin/migrate`) in staging before the swap.
4. **Silent failures:** no `set -e`, and an unknown action does nothing and exits 0.
5. **Unquoted paths** in remote commands.
6. **`build` is Oak-specific:** it copies `assets/images/` and deletes `*.pbm`, and fails or
   misbehaves when those don't exist.
7. **Host keys are never checked** (`StrictHostKeyChecking=no` everywhere).
8. **`release` can take the site down:** if the staging folder is missing, the live folder is
   already renamed when the chain stops.

## Expected Behavior

Keep the script name, the `case "$ACTION"` dispatcher and the existing environment variables, so
existing callers keep working where possible. Callers by the env-var interface: Oak and majora
(they use their repo copies today, so they can adopt the new version later).

1. **Fail fast.** `set -euo pipefail`. Read optional variables as `${VAR:-}`. An unknown or
   missing action prints the list of actions to stderr and exits `1`. Every action exits
   non-zero when its remote command or rsync fails.
2. **Staging folder (port from the Oak/majora copies).**
   - `workspace_temp_dir`: `${SSH_REMOTE_TEMP_DIR%/}-$CIRCLE_WORKFLOW_WORKSPACE_ID` when
     `CIRCLE_WORKFLOW_WORKSPACE_ID` is set, otherwise `$SSH_REMOTE_TEMP_DIR` (the `0.10.0`
     behavior).
   - `remote_temp_dir`: `workspace_temp_dir` plus `/$DEPLOY_PATH` when `DEPLOY_PATH` is set.
   - `generate_folder`, `upload`, `copy_files`, `link` and `run` use `remote_temp_dir`.
     `release` uses `workspace_temp_dir`.
3. **SSH key.** Keep writing `~/ssh_key` with mode 600, converting literal `\n` to newlines.
   Use the copies' `printf '%s\n' "${SSH_PRIVATE_KEY//\\n/$'\n'}"`; it doesn't depend on `echo`
   or `sed` behavior.
4. **Host key verification (opt-in, backward compatible).** When `SSH_KNOWN_HOSTS` is set (the
   known_hosts line(s) for the host, `\n` escaping allowed as for the key), write it to
   `~/ssh_known_hosts` and use `-o StrictHostKeyChecking=yes -o UserKnownHostsFile=~/ssh_known_hosts`.
   When it isn't set, keep today's `StrictHostKeyChecking=no`. Build the SSH command in one
   helper instead of repeating it in every function.
5. **Quoting.** Quote every remote path. Build remote command strings with a POSIX single-quote
   helper (see Solution → Quoting), so paths with spaces or shell characters can't break or inject into the remote
   command.
6. **`link`.** `ln -sfn "$SOURCE" "<remote_temp_dir>"`, as in the copies: `DEPLOY_PATH` is the
   link path inside staging. Create the link's parent folder first (`mkdir -p` of its dirname),
   so callers don't need a separate `generate_folder`. For backward compatibility: when
   `DEPLOY_PATH` is empty and `TARGET` is set, keep the `0.10.0` form `ln -sfn "$SOURCE" "$TARGET"`.
7. **New action `run`.** Runs `$COMMAND` on the host with the working directory set to
   `remote_temp_dir`: `cd <dir> && <COMMAND>`. The command's exit status is the action's exit
   status. It's generic: Pidgey calls it as `COMMAND="$PHP_BIN bin/migrate" deploy_frontend.sh run`.
   `COMMAND` is passed as is, so the caller is responsible for its quoting. Document that.
8. **`upload`.** Same rsync as today, to `remote_temp_dir`. When `EXCLUDE_FROM` is set, pass
   `--exclude-from="$EXCLUDE_FROM"` (a local file of rsync patterns). Create the remote folder
   first, so `generate_folder` is no longer required before `upload`; keep `generate_folder` as an
   action anyway.
9. **`build`.** Keep `npm run build` as the default, but:
   - allow overriding it with `BUILD_COMMAND` (e.g. `BUILD_COMMAND="yarn build"`);
   - run the `assets/images/` copy and the `*.pbm` cleanup only when `assets/images/` exists.
10. **`release`.** Same swap chain, but first check that the staging folder exists. If it's
    missing, fail before touching the live folder. On a first deploy (no
    live folder yet) skip moving it aside; see Solution → Release on a first deploy for the chain.
    Pidgey keeps no rollback copy, so removing `OLD` stays the default. Optionally, `KEEP_OLD=true`
    skips the final `rm -rf OLD`.
11. **`copy_files`.** Keep it unchanged apart from the staging folder and the quoting.
12. **README.** Document every action and every variable (required/optional, default), the tools
    the calling image must provide (`bash`, `ssh`, `rsync`, and `node`/`npm` for `build`), and a
    CircleCI example of a full workflow: parallel upload jobs into one staging tree, then
    `link`, `run`, and a final `release` job.
13. **Tests**, if the repo has a pattern for testing scripts (e.g. bats). At minimum, cover the
    path helpers, the unknown-action exit code, and the commands built by `link`, `run` and
    `release`, with `ssh`/`rsync` stubbed.

### How Pidgey will use it (for the README example)

```bash
deploy_frontend.sh generate_key_file
# backend job: vendor/ installed with --no-dev, tests and dev files excluded
SOURCE=build/backend/ EXCLUDE_FROM=deploy/exclude.txt deploy_frontend.sh upload
# frontend job: vite build output into the web root's admin/ folder
BUILD_COMMAND="yarn build" deploy_frontend.sh build
SOURCE=dist/ DEPLOY_PATH=public/admin/ deploy_frontend.sh upload
# server-only configuration, kept outside every release
SOURCE="$REMOTE_HOME/pidgey-shared/.env" DEPLOY_PATH=config/.env deploy_frontend.sh link
# migrations inside staging, before the swap
COMMAND="$PHP_BIN bin/migrate" deploy_frontend.sh run
# swap
deploy_frontend.sh release
```

Pidgey's CircleCI images would copy the script with
`COPY --from=darthjee/scripts:0.11.0 /home/scripts/sbin/deploy_frontend.sh /usr/local/sbin/`.

## Solution

Decisions taken while refining the issue; where they differ from the list above, this section wins.

### Versioning

- Create the version with `bin/script.sh init scripts 0.11.0` (copies `scripts/0.10.0/` and bumps
  `scripts=` in `version`), then change `home/sbin/deploy_frontend.sh`, `README.md` and add `test/`.
- Only `deploy_frontend.sh` changes; the other `builder/` and `sbin/` scripts stay as they are.

### Release on a first deploy

The live folder may not exist yet. Only move it aside when it exists, so the first release just
moves staging into place:

```
test -d STAGING && { [ ! -e LIVE ] || { rm -rf OLD && mv LIVE OLD; }; } && mv STAGING LIVE && rm -rf OLD
```

(`rm -rf OLD` at the end is skipped with `KEEP_OLD=true`.) A missing staging folder still fails
before the live folder is touched.

### Quoting

Use a small POSIX single-quote helper instead of `printf '%q'`: wrap each value in `'...'` and
turn every inner `'` into `'\''`. `%q` can produce bash-only `$'...'` forms, which a POSIX `sh`
login shell on the host would misread. Every remote path goes through the helper. `COMMAND` (for
`run`) is still passed as is.

### Edge cases

- `SSH_PORT` becomes optional, with default `22`.
- Every other required variable (`SSH_USER`, `SSH_HOST`, `SSH_REMOTE_TEMP_DIR`, `SSH_REMOTE_DIR`
  for `release`/`copy_files`, `SOURCE` for `upload`/`link`, `COMMAND` for `run`,
  `SSH_PRIVATE_KEY` for `generate_key_file`) is read with `${VAR:?message}`, so a missing one
  fails with a clear message. Each action checks only the variables it uses.
- `link` with neither `DEPLOY_PATH` nor `TARGET` exits `1` with a message, instead of linking
  over the staging folder.

### Testing strategy

- Add `scripts/0.11.0/test/` following the repo's image-test pattern (`test.sh` plus
  `subtests/`, run with `bin/script.sh test scripts`).
- Plain bash tests, no bats. `ssh` and `rsync` are stubbed by scripts placed first on `PATH`,
  which record their arguments, so the tests assert on the exact commands built.
- The `scripts` image is `alpine` with only `curl` and `jq`, and has no `app` user, so the shared
  `Dockerfile.test` (which runs `chown $USER_NAME:$USER_NAME`) can't test it as is. Extend the
  shared harness: `bin/image.sh test` uses a per-version test Dockerfile when one exists (e.g.
  `scripts/0.11.0/test/Dockerfile`), and falls back to the root `Dockerfile.test` otherwise. The
  scripts test Dockerfile installs `bash` (and `rsync` only if a test needs the real binary) in
  the test image only, never in the published image.
- Every other image keeps testing exactly as today; check that `bin/script.sh test` for an
  existing image (e.g. `taa`) still passes.
- Cover at least: the path helpers (with and without `CIRCLE_WORKFLOW_WORKSPACE_ID` and
  `DEPLOY_PATH`), the unknown/missing action exit code, the quoting helper with spaces and
  quotes, and the commands built by `link` (both forms), `run`, `upload` (with `EXCLUDE_FROM`)
  and `release` (with and without `KEEP_OLD`).

### Scope and backward compatibility

- In scope: `scripts/0.11.0/` (script, README, tests), the `version` bump, and the
  per-version test Dockerfile support in `bin/image.sh` (plus `docker-compose.yml` if the
  Dockerfile path has to come from there).
- Out of scope: bumping the images in this repo that copy from `darthjee/scripts` (they stay
  pinned to their current versions), and moving Oak/majora off their repo copies. Each can adopt
  `0.11.0` later in its own issue.
- A caller that works with `0.10.0` keeps working unchanged: no workspace suffix without
  `CIRCLE_WORKFLOW_WORKSPACE_ID`, `link` with `TARGET` and no `DEPLOY_PATH` keeps the old form (now
  `-sfn`), no host-key check without `SSH_KNOWN_HOSTS`, and `generate_folder` is kept.
- The intended behavior change: failures that `0.10.0` ignored (rsync/ssh errors, unknown action,
  missing variables) now fail the job.
- No `circleci_`/`production_` counterparts; the Dockerfile is unchanged, so there's no layer or
  multi-arch impact.

## Benefits

- Pidgey (and later Oak/majora) can take `deploy_frontend.sh` from `darthjee/scripts:0.11.0`
  instead of keeping per-project copies.
- Deploy failures stop the CI job instead of passing silently, and a missing staging folder can
  no longer take the live site down.
- Paths are quoted safely, host keys can be verified, and migrations can run in staging before
  the swap.
