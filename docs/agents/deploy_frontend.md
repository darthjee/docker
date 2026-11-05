# deploy_frontend.sh

Agent notes for `deploy_frontend.sh`, the deploy script shipped in the `scripts` image (`scripts/<version>/home/sbin/deploy_frontend.sh`, at `/home/scripts/sbin/deploy_frontend.sh` in `darthjee/scripts`). Other images copy it in (e.g. `darthjee/tent`, at `/usr/sbin/deploy_frontend.sh`), and projects call it from CircleCI jobs.

## Reference

The reference is the `## deploy_frontend.sh` section of `scripts/<version>/README.md`, with `<version>` taken from the `scripts=` line of the root [`version`](../../version) file. It covers:

- the actions (with the folder each one operates on) and the variables with their defaults;
- the staging model (workspace folder vs. target folder);
- `### Failure and recovery`: re-run safety per action, `release` failure modes, manual rollback with `KEEP_OLD=true`;
- `### Cleanup`: how `cleanup` keeps `SSH_REMOTE_DIR` and its `_old_*` folders, the recommended layout for `SSH_REMOTE_DIR` vs. `SSH_REMOTE_TEMP_DIR`, and the glob-character caveat;
- `### Pitfalls`: `SOURCE` trailing slash, `link` caveats, concurrent deploys;
- the CircleCI example, with `cleanup` in its own job.

Read it there; this file does not repeat its tables. What follows is version history only.

## Versions

- The 0.10.0 script is byte-identical to 0.9.0's: the migration table below applies to both.
- 0.11.0 → 0.12.0 only adds the `cleanup` action: callers already on 0.11.0 have no breaking changes.
- 0.12.0 → 0.13.0: `cleanup` now never removes `SSH_REMOTE_DIR` or `${SSH_REMOTE_DIR}_old_*` when they are in the same parent folder as the staging folders. No breaking changes.

## Migration: 0.9.0 / 0.10.0 → 0.12.0 / 0.13.0

Verified against `scripts/0.9.0/home/sbin/deploy_frontend.sh` and `scripts/0.12.0/home/sbin/deploy_frontend.sh`. Everything below also applies to 0.13.0, which only changes `cleanup` (see [Migration: 0.12.0 → 0.13.0](#migration-0120--0130)).

| # | 0.9.0 / 0.10.0 | 0.12.0 | Impact |
|---|---|---|---|
| 1 | No or unknown action: silent, exit 0 (the `case` has no default branch) | Usage printed to **stderr**, exit 1 | Breaking for callers with a typo or no action |
| 2 | No `set -e`; missing variables run anyway | `set -euo pipefail` and `${VAR:?}` fail fast | Breaking for callers relying on empty variables (e.g. an empty `SSH_PRIVATE_KEY` used to write an empty key file) |
| 3 | `SSH_PORT` must be set (an empty value gives `-p -o …`, so ssh fails with "Bad port") | Defaults to 22 | Fix |
| 4 | Remote paths unquoted: a **literal** `~` (e.g. a CircleCI project variable set to `~/www`) was expanded by the remote shell; paths with spaces broke | Remote paths single-quoted: `~` and globs are **not** expanded remotely; spaces work | Breaking for literal `~` values; use absolute paths. A `~` typed in a local shell command (`SSH_REMOTE_DIR=~/www …`) is expanded by the local shell in both versions, which was already wrong. |
| 5 | Staging dir is `SSH_REMOTE_TEMP_DIR` | When `CIRCLE_WORKFLOW_WORKSPACE_ID` is set (always on CircleCI), staging is `${SSH_REMOTE_TEMP_DIR%/}-$CIRCLE_WORKFLOW_WORKSPACE_ID` | Breaking for callers doing their own ssh against the temp dir. `cleanup` only matches `<base>-*`, so a plain `SSH_REMOTE_TEMP_DIR` left by a failed 0.9.0 deploy is never removed: delete it once by hand after migrating. |
| 6 | `release` runs `rm old && mv live old && mv temp live && rm old`: it fails if the live dir is missing, and if **staging is missing it moves the live folder aside and then fails, leaving no live folder** | Checks that staging exists before touching anything, tolerates a missing live dir, `KEEP_OLD=true` keeps the old copy | Safety fix |
| 7 | `link` is `ln -s SOURCE TARGET` (fails if `TARGET` already exists as a file or a link to one) | Without `DEPLOY_PATH`: `ln -sfn SOURCE TARGET` (replaces). **With `DEPLOY_PATH` set, `TARGET` is ignored** and the link is created at `DEPLOY_PATH` inside staging. `SSH_REMOTE_TEMP_DIR` is now required even when only `TARGET` is used. | Breaking for callers that set `DEPLOY_PATH` at project/job level (for `upload`) and call `link` with `TARGET`: the link silently lands elsewhere |
| 8 | `build`'s exit status was its last command (`rm -f $(find …)`), so **a failing `npm run build` still exited 0**; `rsync` of `assets/images/` ran unconditionally | `build` fails when the build command fails; the images sync only runs if `assets/images/` exists | Breaking in a good way: builds that were silently failing now fail the job |
| 9 | `upload` didn't create the staging dir; `generate_folder` had to run first | `upload` runs `mkdir -p` itself | Compatible; `generate_folder` before `upload` is now optional (still required before `copy_files`) |
| 10 | Host keys never checked (`StrictHostKeyChecking=no`) | Still `no` by default; pinned (`StrictHostKeyChecking=yes`) when `SSH_KNOWN_HOSTS` is set | Compatible, opt-in. Recommend `SSH_KNOWN_HOSTS`. |
| 11 | — | New actions `run`, `cleanup`; new variables `DEPLOY_PATH`, `EXCLUDE_FROM`, `BUILD_COMMAND`, `COMMAND`, `KEEP_OLD`, `CLEANUP_MAX_AGE_MINUTES`, `SSH_KNOWN_HOSTS` | Additive |

Not a difference: `generate_key_file` converts literal `\n` into newlines the same way in both versions (`sed` in 0.9.0, `printf` in 0.12.0).

### Example: row 4 and row 7

```bash
# 0.9.0: worked because the remote shell expanded the literal ~
SSH_REMOTE_DIR='~/www'
# 0.12.0: use the absolute path
SSH_REMOTE_DIR=/home/<user>/www

# 0.12.0: DEPLOY_PATH set for the job (e.g. for upload) wins over TARGET in link
DEPLOY_PATH=public/admin SOURCE=/home/<user>/shared/.env TARGET=<target> deploy_frontend.sh link
# -> link created at <workspace folder>/public/admin, not at <target>
# Unset DEPLOY_PATH for that call, or give link its own DEPLOY_PATH:
DEPLOY_PATH=config/.env SOURCE=/home/<user>/shared/.env deploy_frontend.sh link
```

### Migration checklist

1. Use absolute remote paths: no literal `~` in `SSH_REMOTE_DIR` / `SSH_REMOTE_TEMP_DIR` (row 4).
2. Check where `DEPLOY_PATH` is set relative to `link` calls that use `TARGET` (row 7).
3. Expect builds that were silently failing to fail now (row 8).
4. Delete the leftover plain `SSH_REMOTE_TEMP_DIR` on the host once (row 5).
5. Add a `cleanup` job that requires the release job (see the README's `### Failure and recovery` and CircleCI example).
6. Prefer keeping `SSH_REMOTE_DIR` and `SSH_REMOTE_TEMP_DIR` in separate parent folders (e.g. `/srv/app/live` + `/srv/app/staging`). From 0.13.0 this is a recommendation: a live folder matching `<basename of SSH_REMOTE_TEMP_DIR>-*` in the same parent is no longer deleted by `cleanup`. **On 0.12.0 it is still required**, otherwise `cleanup` can delete the live folder and its `_old_*` backups.

## Migration: 0.12.0 → 0.13.0

No breaking changes. In 0.12.0, `cleanup` removed every old folder matching `<basename of SSH_REMOTE_TEMP_DIR>-*`, including `SSH_REMOTE_DIR` and its `_old_*` folders when their names matched. In 0.13.0, when `SSH_REMOTE_DIR` is set and shares the staging parent folder, `cleanup` adds `! -name '<live base>' ! -name '<live base>_old_*'` to its `find`. `SSH_REMOTE_DIR` stays optional for `cleanup`; when it is unset, or in another parent folder, the command is the same as in 0.12.0.

- Upgrade to 0.13.0 to drop the 0.12.0 naming-rule workaround, or keep the separate-parent layout, which stays the recommended one because it is clearer.
- Set `SSH_REMOTE_DIR` in the `cleanup` job too, otherwise the live folder is not excluded.
- A `*`, `?` or `[` in the live folder's basename widens the exclusion: `cleanup` may keep more folders, never fewer.

## Other gotchas

- **`build` needs node unless `BUILD_COMMAND` is set:** it runs `${BUILD_COMMAND:-npm run build}`. In images without node (e.g. `darthjee/tent`), set `BUILD_COMMAND` or skip `build`. It syncs `assets/images/` into `dist/` only if that folder exists. See the README's `build` action and `BUILD_COMMAND` variable rows.
- **`$HOME` must be writable:** `generate_key_file` writes `$HOME/ssh_key` and `$HOME/ssh_known_hosts` (mode 600), and the remote actions read them from there (the key always, the known_hosts file when `SSH_KNOWN_HOSTS` is set). See the README's `generate_key_file` row.
- **`COMMAND` quoting:** `run` sends `COMMAND` as is, so the caller is responsible for its quoting. It runs inside the target folder (`cd <target folder> && $COMMAND`). See the README's `COMMAND` variable row.
- **`cleanup` and glob characters in `SSH_REMOTE_TEMP_DIR`:** see the README's `### Cleanup` section; not repeated here.

## Out of scope here

- Code fixes: bounding the `${SSH_REMOTE_DIR}_old_*` folders left by `KEEP_OLD=true` is [#250](https://github.com/darthjee/docker/issues/250).
