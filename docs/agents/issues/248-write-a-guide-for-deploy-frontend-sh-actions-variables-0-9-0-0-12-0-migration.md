# Issue: Write a guide for deploy_frontend.sh (actions, variables, 0.9.0 → 0.12.0 migration)

## Description

`scripts/<version>/home/sbin/deploy_frontend.sh` (shipped in `darthjee/scripts` at `/home/scripts/sbin/deploy_frontend.sh`) is copied into other images, such as `darthjee/tent` (`/usr/sbin/deploy_frontend.sh`), and called from CircleCI jobs in several projects. `scripts/0.12.0/README.md` already has a `deploy_frontend.sh` reference (actions, variables with defaults, staging model, CircleCI example, runtime requirements), but nothing in `docs/agents/` points to it, and it has gaps.

Raised while refining darthjee/tent#301, which moves the tent image from scripts 0.9.0 to 0.12.0. Refined with input from a review comment on this issue (workspace root vs. `DEPLOY_PATH`, `KEEP_OLD` vs. rollback, `cleanup` failure vs. `release` failure).

## Problem

- There is no migration guide: several 0.12.0 behaviours break callers written against 0.9.0/0.10.0, and nothing lists them.
- The README is silent on failure and recovery: which actions are safe to re-run, how `release` can fail part-way (including leaving no live folder), and how to roll back with `KEEP_OLD=true`.
- The README states that `cleanup` never removes the live or `_old_*` folders, which is false when the folder names collide (code fix tracked in #249).
- Several caller pitfalls are undocumented: `~` not expanded remotely, `$HOME` must be writable, `copy_files` needing its folder created first, a trailing slash on `SOURCE`, `link` caveats, concurrent deploys.
- LLM agents have no entry point from `AGENTS.md` / `docs/agents/`.

## Expected Behavior

An agent or person wiring `deploy_frontend.sh` into a project finds `docs/agents/deploy_frontend.md` from `AGENTS.md`. From there they reach the current version's README for the reference, which also covers failure, recovery and edge cases. Someone migrating from 0.9.0/0.10.0 gets a verified table of differences and a checklist.

## Solution

Complete the existing `deploy_frontend.sh` reference in `scripts/0.12.0/README.md` (actions, variables with defaults, staging model, CircleCI example and runtime requirements are already there) with the current-behaviour gotchas and failure/recovery notes. Add an agent-facing `docs/agents/deploy_frontend.md` holding the 0.9.0 → 0.12.0 migration notes and pointing to the README. See [Scope](#scope) for the exact split. Write for LLM agents: precise and example-driven.

### Findings to include (0.9.0/0.10.0 → 0.12.0)

Verified against the 0.9.0 and 0.12.0 sources. Version facts the guide must state up front:

- The 0.10.0 script is byte-identical to 0.9.0's, so the table applies to both.
- 0.11.0 → 0.12.0 only adds the `cleanup` action: callers already on 0.11.0 have no breaking changes.

| # | 0.9.0 / 0.10.0 | 0.12.0 | Impact |
|---|---|---|---|
| 1 | No or unknown action: silent, exit 0 (the `case` has no default branch) | Usage printed to **stderr**, exit 1 | Breaking for callers with a typo or no action |
| 2 | No `set -e`; missing variables run anyway | `set -euo pipefail` and `${VAR:?}` fail fast | Breaking for callers relying on empty variables (e.g. an empty `SSH_PRIVATE_KEY` used to write an empty key file) |
| 3 | `SSH_PORT` must be set (an empty value gives `-p -o …`, so ssh fails with "Bad port") | Defaults to 22 | Fix |
| 4 | Remote paths unquoted: a **literal** `~` (e.g. a CircleCI project variable set to `~/www`) was expanded by the remote shell; paths with spaces broke | Remote paths single-quoted: `~` and globs are **not** expanded remotely; spaces work | Breaking for literal `~` values; use absolute paths. A `~` typed in a local shell command (`SSH_REMOTE_DIR=~/www …`) is expanded by the local shell in both versions, which was already wrong. |
| 5 | Staging dir is `SSH_REMOTE_TEMP_DIR` | When `CIRCLE_WORKFLOW_WORKSPACE_ID` is set (always on CircleCI), staging is `${SSH_REMOTE_TEMP_DIR%/}-$CIRCLE_WORKFLOW_WORKSPACE_ID` | Breaking for callers doing their own ssh against the temp dir. `cleanup` only matches `<base>-*`, so a plain `SSH_REMOTE_TEMP_DIR` left by a failed 0.9.0 deploy is never removed: delete it once by hand after migrating. |
| 6 | `release` runs `rm old && mv live old && mv temp live && rm old`: it fails if the live dir is missing, and if **staging is missing it moves the live folder aside and then fails, leaving no live folder** | Checks that staging exists before touching anything, tolerates a missing live dir, `KEEP_OLD=true` keeps the old copy | Safety fix |
| 7 | `link` is `ln -s SOURCE TARGET` (fails if the link exists) | Without `DEPLOY_PATH`: `ln -sfn SOURCE TARGET` (replaces). **With `DEPLOY_PATH` set, `TARGET` is ignored** and the link is created at `DEPLOY_PATH` inside staging. `SSH_REMOTE_TEMP_DIR` is now required even when only `TARGET` is used. | Breaking for callers that set `DEPLOY_PATH` at project/job level (for `upload`) and call `link` with `TARGET`: the link silently lands elsewhere |
| 8 | `build`'s exit status was its last command (`rm -f $(find …)`), so **a failing `npm run build` still exited 0**; `rsync` of `assets/images/` ran unconditionally | `build` fails when the build command fails; the images sync only runs if `assets/images/` exists | Breaking in a good way: builds that were silently failing now fail the job |
| 9 | `upload` didn't create the staging dir; `generate_folder` had to run first | `upload` runs `mkdir -p` itself | Compatible; `generate_folder` before `upload` is now optional (still required before `copy_files`) |
| 10 | Host keys never checked (`StrictHostKeyChecking=no`) | Still `no` by default; pinned (`StrictHostKeyChecking=yes`) when `SSH_KNOWN_HOSTS` is set | Compatible, opt-in. Recommend `SSH_KNOWN_HOSTS`. |
| 11 | — | New actions `run`, `cleanup`; new variables `DEPLOY_PATH`, `EXCLUDE_FROM`, `BUILD_COMMAND`, `COMMAND`, `KEEP_OLD`, `CLEANUP_MAX_AGE_MINUTES`, `SSH_KNOWN_HOSTS` | Additive |

Not a difference: `generate_key_file` converts literal `\n` the same way in both versions (`sed` vs `printf`).

### Migration checklist (0.9.0/0.10.0 → 0.12.0)

1. Use absolute remote paths: no literal `~` in `SSH_REMOTE_DIR` / `SSH_REMOTE_TEMP_DIR`.
2. Check where `DEPLOY_PATH` is set relative to `link` calls that use `TARGET` (row 7).
3. Expect builds that were silently failing to fail now (row 8).
4. Delete the leftover plain `SSH_REMOTE_TEMP_DIR` on the host once (row 5).
5. Add a `cleanup` job that requires the release job (see the failure and recovery section).
6. Check that `SSH_REMOTE_DIR` doesn't match `<basename of SSH_REMOTE_TEMP_DIR>-*` (edge case 1, #249).

Other gotchas worth stating:

- `build` runs `${BUILD_COMMAND:-npm run build}`. In images without node (e.g. `darthjee/tent`), set `BUILD_COMMAND` or skip `build`. It also syncs `assets/images/` into `dist/` only if that folder exists.
- `generate_key_file` writes `$HOME/ssh_key` and `$HOME/ssh_known_hosts` (mode 600), so `$HOME` must be writable by the running user.
- `COMMAND` (for `run`) is sent as is, so the caller is responsible for its quoting. It runs inside the staging dir.

## Scope

`scripts/0.12.0/README.md` (section `deploy_frontend.sh`) already documents every action, every variable with its default, the runtime requirements, the workspace-folder vs. target-folder model and a full CircleCI example. This issue does **not** duplicate that material. It splits the missing content by its nature:

### 1. Current behaviour → `scripts/0.12.0/README.md`

Facts about how 0.12.0 behaves go next to the action and variable tables they qualify. That way they reach Docker Hub readers and are inherited when the README is carried forward to later versions:

- `release` moves the whole workspace folder and ignores `DEPLOY_PATH`. State this explicitly in the `release` row: a caller must not infer that `release` publishes only the `DEPLOY_PATH` subdirectory.
- Remote paths are single-quoted, so `~` and globs are **not** expanded on the remote host. Use absolute paths (e.g. not `SSH_REMOTE_DIR=~/www`).
- `generate_key_file` writes `$HOME/ssh_key` / `$HOME/ssh_known_hosts`, so `$HOME` must be writable by the running user.
- An "Operates on" column in the actions table, and a failure and recovery section: see [README: operates-on, failure and recovery](#readme-operates-on-failure-and-recovery).

### 2. Version history → new `docs/agents/deploy_frontend.md`

- The 0.9.0 → 0.12.0 migration table and the gotchas listed below. Version history doesn't fit a single version's Docker Hub description, and it would go stale if later READMEs inherited it.
- A pointer to the reference: "see the `deploy_frontend.sh` section of `scripts/<version>/README.md`, with `<version>` from the `scripts=` line of the root `version` file". The version is not hard-coded, so the pointer needs no bump on each scripts release. The agent doc never repeats the action and variable tables.
- A row for it in the documentation table of `AGENTS.md`.

## README: operates-on, failure and recovery

Refined from a review comment on this issue, checked against the 0.12.0 source (`scripts/0.12.0/home/sbin/deploy_frontend.sh`).

### "Operates on" column in the actions table

Add a column to the existing actions table rather than a new table. No "evidence in source/test" column: such references go stale with each version and don't help callers.

| Action | Operates on |
|---|---|
| `generate_key_file`, `build` | local |
| `generate_folder`, `copy_files`, `upload`, `link`, `run` | target folder (workspace folder + `DEPLOY_PATH`) |
| `release` | **workspace folder** (`DEPLOY_PATH` ignored) → live folder |
| `cleanup` | sibling `<basename>-*` folders of the workspace folder |

### Re-run safety per action

| Action | Re-run safe? | Why |
|---|---|---|
| `generate_key_file`, `generate_folder`, `upload`, `link`, `cleanup` | yes | overwrite / `mkdir -p` / rsync / `ln -sfn` / `find -mmin` |
| `copy_files` | yes | copies again over the earlier copy |
| `build`, `run` | depends on `BUILD_COMMAND` / `COMMAND` | e.g. a migration may not be safe to re-run: the caller decides |
| `release` | **check remote state first** | see below |

### `release` failure modes

`release` is one `&&` chain: `test -d staging` → (`rm -rf old && mv live old`) → `mv staging live` → `rm -rf old` (unless `KEEP_OLD=true`). A non-zero exit doesn't say which step failed:

- `test -d` fails: nothing was touched. This is also what re-running `release` after it succeeded looks like, because staging is gone.
- First `mv` succeeded, second failed: **no live folder exists**. The previous live copy is at `${SSH_REMOTE_DIR}_old_<timestamp>`; restore it with `mv`.
- Final `rm -rf old` failed: the deploy **succeeded**, but the action exits non-zero and the old folder is left behind.
- ssh connection lost: the state is unknown.

The guide must say: inspect the live, staging and `_old_*` folders on the host before replaying any effectful action. A non-zero ssh result does not prove nothing changed.

### `KEEP_OLD=true` is manual rollback, not automatic

- Rollback procedure: move the live folder aside, then `mv` the newest `${SSH_REMOTE_DIR}_old_<timestamp>` back to `SSH_REMOTE_DIR`. Show the exact ssh command, using placeholders only (no real hosts or keys).
- `cleanup` never removes `_old_*` folders, so with `KEEP_OLD=true` they pile up until the caller prunes them.
- Without `KEEP_OLD`, the only rollback is redeploying the previous commit.

### `cleanup` in its own CircleCI job

CircleCI keeps `CIRCLE_WORKFLOW_WORKSPACE_ID` the same on "Rerun workflow from failed". If `cleanup` fails in the same job as `release`, the rerun repeats the whole job and `release` fails at `test -d`, because staging was already moved. So:

- Change the README's CircleCI example so `cleanup` runs in a separate job that `requires` the release job. Rerun-from-failed then retries only `cleanup`.
- State that a `cleanup` failure does not mean the deploy failed: the next deploy's `cleanup` catches up.
- The implementer should confirm the `CIRCLE_WORKFLOW_WORKSPACE_ID` rerun behaviour against CircleCI's documentation and cite it.

## README: edge cases

Additional current-behaviour edge cases for `scripts/0.12.0/README.md`, checked against the 0.12.0 source.

1. **`cleanup` vs. a colliding live folder.** The README currently says `cleanup` never removes the live folder or the `${SSH_REMOTE_DIR}_old_*` folders. That is only true when names don't collide: `cleanup` runs `find <parent> -name '<base>-*' -mmin +<age> -exec rm -rf` with no exclusion for `SSH_REMOTE_DIR`. With `SSH_REMOTE_TEMP_DIR=/var/www/app` and `SSH_REMOTE_DIR=/var/www/app-live`, both `app-live` and every `app-live_old_<ts>` match `app-*`. The `_old_*` copies kept by `KEEP_OLD=true` are old by definition, so they get silently deleted, which breaks manual rollback. The live folder is also at risk when `cleanup` runs outside a deploy, or when an upload took longer than `CLEANUP_MAX_AGE_MINUTES`. The test (`test/subtests/cleanup.sh`) only passes because it uses non-colliding names. Docs for this issue:
   - correct the "never removes" claim;
   - add a hard rule: `SSH_REMOTE_DIR` (and so `${SSH_REMOTE_DIR}_old_*`) must not match `<basename of SSH_REMOTE_TEMP_DIR>-*` in the same parent folder;
   - show a safe layout, e.g. `SSH_REMOTE_DIR=/srv/app/live`, `SSH_REMOTE_TEMP_DIR=/srv/app/staging`.

   The code fix is tracked in #249.
2. **`copy_files` doesn't create the target folder.** Unlike `upload`, it has no `mkdir -p`. Run `generate_folder` (or `upload`) before it, or `cp -R` fails.
3. **A trailing slash on `SOURCE` matters for `upload`** (rsync semantics): `SOURCE=dist/` uploads the folder's contents, `SOURCE=dist` uploads the `dist/` folder itself.
4. **`link`:**
   - `SOURCE` should be an absolute path: the link moves with staging when `release` runs, so a relative target resolves against the link's new location.
   - If `DEPLOY_PATH` already exists as a real folder in staging (e.g. something was uploaded there), `ln -sfn` creates the link *inside* that folder instead of replacing it.
5. **Two workflows deploying at once.** Each workflow gets its own staging folder, and whichever `release` runs last wins. Two releases in the same second share the `_old_<timestamp>` name, so the second's `rm -rf old` deletes the first's backup. Recommend running deploys one at a time, e.g. with a CircleCI serial group or a branch filter.

Not included: re-running `copy_files` merges into `dir/<basename>` with both GNU and BusyBox `cp` (only stale files are left behind, which the re-run table already covers). The `cleanup` glob-character caveat is already in the README; the agent doc links to it.

## Out of scope

- Any code change to `deploy_frontend.sh` (the `cleanup` collision bug is #249), bounding the `${SSH_REMOTE_DIR}_old_*` folders left by `KEEP_OLD=true` (#250, which also notes a possible `rollback` action as a follow-up).
- Updating the READMEs of older scripts versions (0.9.0, 0.10.0, 0.11.0).
- No new image version: a README-only change is published as the Docker Hub description without re-pushing the image.

## Acceptance criteria

- `scripts/0.12.0/README.md` states that `release` ignores `DEPLOY_PATH`, that `~`/globs are not expanded remotely, that `$HOME` must be writable, and documents failure/recovery (re-run safety per action, manual rollback with `KEEP_OLD=true`).
- The README actions table has an "Operates on" column, and the README has a failure and recovery section covering the `release` failure modes, re-run safety, manual rollback and `_old_*` accumulation.
- The README's CircleCI example runs `cleanup` in its own job that requires the release job.
- The README no longer claims `cleanup` never removes the live/`_old_*` folders; it states the naming rule with a safe layout, and documents the `copy_files` ordering requirement, the `SOURCE` trailing-slash behaviour, the `link` caveats and the concurrent-deploy caveat.
- `docs/agents/deploy_frontend.md` exists with the version note (0.10.0 = 0.9.0; 0.11.0 → 0.12.0 only adds `cleanup`), the 0.9.0/0.10.0 → 0.12.0 migration table (rows 1–11), the migration checklist and the gotchas, and points to the current version's README for the reference without duplicating its tables.
- `AGENTS.md`'s documentation table links `docs/agents/deploy_frontend.md`.

## Benefits

- Safer migrations of consuming images (e.g. `darthjee/tent`) to scripts 0.12.0.
- Fewer production incidents from partial `release` failures, wrong rollbacks or a misnamed live folder.
- No duplicated reference: the README stays the single source for actions and variables.
