darthjee/scripts

Scripts
=======

This repository contains several Docker images, each organized in its own folder and version. This documentation refers to the scripts image.

## About the image

The scripts image is a collection of auxiliary scripts, organized to facilitate both the building of other Docker images and development inside containers.


### Scripts structure

- **builder/**  
  Scripts mainly used during the build process of other Docker images. Below is a list of available builder scripts:
  - `bower_builder.sh`: Installs Bower dependencies and manages Bower cache for reproducible builds.
  - `bundle_builder.sh`: Installs Ruby gems using Bundler and manages gem cache for efficient builds.
  - `poetry_builder.sh`: Installs Python dependencies using Poetry, handling cache and new package management for Python projects.
  - `yarn_builder.sh`: Installs Node.js dependencies using Yarn, managing both global and user-level cache for faster and reproducible builds.



- **sbin/**  
  Scripts added to the final images for use during development. Below is a list of available sbin scripts:
  - `build_gem.sh`: Automates the process of building and releasing Ruby gems, ensuring version and tag consistency.
  - `check_gems.sh`: Checks for missing or outdated Ruby gems and can upgrade all gems as needed.
  - `check_readme.sh`: Verifies if the README contains a link to the correct RubyDoc documentation for the current gem version.
  - `check_specs`: Runs automated tests based on configuration, supporting custom test file discovery.
  - `deploy_frontend.sh`: Builds assets, uploads them to a staging folder on a remote server using SSH and rsync, and swaps the staging folder into place (see [deploy_frontend.sh](#deploy_frontendsh)).
  - `docker_hub.sh`: Handles Docker Hub authentication and allows pushing updated repository descriptions via the Docker Hub API.
  - `rubycritic.sh`: Runs RubyCritic on changed files to provide code quality reports for Ruby projects.

## deploy_frontend.sh

`deploy_frontend.sh <action>` deploys files to a remote host through a staging folder:
every job uploads into the same staging tree, and a final `release` swaps it with the
live folder. It stops on the first error: an unknown or missing action prints the list
of actions to stderr and exits `1`, a missing required variable exits with a message, and
a failing `ssh`, `rsync` or remote command fails the action.

The image that runs it must provide `bash`, `ssh` and `rsync`, plus `node`/`npm` (or the
tool used by `BUILD_COMMAND`) for `build`.

### Staging folder

- **Workspace folder:** `${SSH_REMOTE_TEMP_DIR%/}-$CIRCLE_WORKFLOW_WORKSPACE_ID` when
  `CIRCLE_WORKFLOW_WORKSPACE_ID` is set, so every job of a CircleCI workflow fills the same
  staging tree; otherwise `$SSH_REMOTE_TEMP_DIR` as is. `release` moves this folder.
- **Target folder:** the workspace folder plus `/$DEPLOY_PATH` when `DEPLOY_PATH` is set
  (trailing slashes are ignored). `generate_folder`, `copy_files`, `upload`, `link` and `run`
  work on this folder.

Every remote path is single-quoted before being sent over ssh, so paths with spaces or
shell characters are safe, and the remote login shell may be a POSIX `sh`. For the same
reason, `~` and globs are **not** expanded on the remote host: use absolute paths (e.g.
`SSH_REMOTE_DIR=/home/<user>/www`, not `SSH_REMOTE_DIR=~/www`).

### Actions

| Action | Operates on | What it does |
|--------|-------------|--------------|
| `generate_key_file` | local | Writes `SSH_PRIVATE_KEY` to `$HOME/ssh_key` (mode 600), turning literal `\n` into newlines. When `SSH_KNOWN_HOSTS` is set, writes it the same way to `$HOME/ssh_known_hosts`. `$HOME` must be writable by the user running the script. |
| `build` | local | Runs `BUILD_COMMAND`. When `assets/images/` exists, copies it to `dist/assets/images/` and deletes the `*.pbm` files there. |
| `generate_folder` | target folder | Creates the target folder on the host (`mkdir -p`). |
| `copy_files` | target folder | Copies `$SSH_REMOTE_DIR/$TARGET` from the live folder into the target folder. It does not create the target folder: run `generate_folder` (or `upload`) first. |
| `upload` | target folder | Creates the target folder, then uploads `SOURCE` into it with `rsync -avz`, passing `--exclude-from="$EXCLUDE_FROM"` when set. |
| `link` | target folder | With `DEPLOY_PATH`: creates the link's parent folder and runs `ln -sfn "$SOURCE" <target folder>`, so `DEPLOY_PATH` is the link path inside staging. Without `DEPLOY_PATH` but with `TARGET`: `ln -sfn "$SOURCE" "$TARGET"`. With neither, exits `1`. |
| `run` | target folder | Runs `cd <target folder> && $COMMAND` on the host; the command's exit status is the action's. |
| `release` | **workspace folder** → live folder | Checks that the workspace folder exists (and fails before touching anything if it doesn't), moves the live folder aside to `${SSH_REMOTE_DIR}_old_<timestamp>` when it exists, moves the workspace folder to `SSH_REMOTE_DIR` and removes the old folder unless `KEEP_OLD=true`. **`DEPLOY_PATH` is ignored:** `release` always publishes the whole workspace folder, never only the `DEPLOY_PATH` subfolder. |
| `cleanup` | sibling `<basename>-*` folders of the workspace folder | Removes the `${SSH_REMOTE_TEMP_DIR%/}-*` folders (direct matches only) whose modification time is older than `CLEANUP_MAX_AGE_MINUTES`, such as the ones left by workflows that failed before `release`. It never removes the current workspace folder (when `CIRCLE_WORKFLOW_WORKSPACE_ID` is set) or the plain `SSH_REMOTE_TEMP_DIR`. When `SSH_REMOTE_DIR` is set and is in the same parent folder, it also never removes `SSH_REMOTE_DIR` or the `${SSH_REMOTE_DIR}_old_*` folders, even when their names match `<basename>-*` (see [Cleanup](#cleanup)). Exits `0` when the staging folder's parent does not exist. |

"Target folder" is the workspace folder plus `DEPLOY_PATH` (see [Staging folder](#staging-folder)).

### Failure and recovery

Every action stops on its first error, but a non-zero exit does not prove that nothing
changed on the host: an action may fail after some of its remote commands ran, and a lost
ssh connection leaves the remote state unknown. **Before replaying any effectful action
(`copy_files`, `link`, `run`, `release`, `cleanup`), inspect the live, staging and
`${SSH_REMOTE_DIR}_old_*` folders on the host**, e.g.:

```bash
ssh -p <port> <user>@<host> "ls -ld '<remote_dir>' '<remote_dir>'_old_* '<remote_temp_dir>'-*"
```

#### Re-run safety

| Action | Re-run safe? | Why |
|--------|--------------|-----|
| `generate_key_file`, `generate_folder`, `upload`, `link`, `cleanup` | yes | overwrite / `mkdir -p` / rsync / `ln -sfn` / `find -mmin` |
| `copy_files` | yes | copies again over the earlier copy (files deleted from the source since are left behind) |
| `build`, `run` | depends on `BUILD_COMMAND` / `COMMAND` | e.g. a migration may not be safe to re-run: the caller decides |
| `release` | **check the remote state first** | see below |

#### `release` failure modes

`release` sends one `&&` chain to the host:

1. `test -d <workspace folder>`;
2. when the live folder exists: `rm -rf <old>` then `mv <live> <old>`, with
   `<old>` = `${SSH_REMOTE_DIR}_old_<timestamp>`;
3. `mv <workspace folder> <live>`;
4. `rm -rf <old>`, unless `KEEP_OLD=true`.

The exit status alone does not say which step failed:

- **Step 1 failed:** nothing was touched. This is also what re-running `release` after a
  successful `release` looks like, since the workspace folder has already been moved.
- **Step 2 succeeded, step 3 failed:** **no live folder exists.** The previous live copy is
  at `${SSH_REMOTE_DIR}_old_<timestamp>`; move it back with `mv` (see below).
- **Step 4 failed:** the deploy **succeeded** (the new release is live), but the action
  exits non-zero and the old folder is left behind.
- **ssh connection lost:** the state is unknown; inspect the host.

#### Rollback

`KEEP_OLD=true` makes rollback possible, but it is manual: `release` only keeps the
previous live folder. To roll back, move the current live folder aside and move the
newest `${SSH_REMOTE_DIR}_old_<timestamp>` back to `SSH_REMOTE_DIR` (placeholders only;
`<remote_dir>` is the absolute value of `SSH_REMOTE_DIR`):

```bash
ssh -p <port> <user>@<host> '
  set -e
  old=$(ls -d <remote_dir>_old_* | sort | tail -n 1)
  mv <remote_dir> <remote_dir>_broken_$(date +%s)
  mv "$old" <remote_dir>
'
```

The `_old_<timestamp>` suffix is a Unix timestamp, so `sort` orders the folders by age.

- `cleanup` does not remove the `${SSH_REMOTE_DIR}_old_*` folders, so with `KEEP_OLD=true`
  they pile up until the caller prunes them.
- Without `KEEP_OLD=true`, the old folder is deleted by `release`: the only rollback is
  redeploying the previous commit.

#### `cleanup` failures

A `cleanup` failure does not mean the deploy failed: `release` has already run, and the
next deploy's `cleanup` removes whatever this one left behind.

### Cleanup

`cleanup` runs `find` on the host over the parent of `SSH_REMOTE_TEMP_DIR`, matching
`-name '<basename>-*'`, and uses only options supported by both GNU and BusyBox `find`.
A folder's age is its own modification time, which changes when entries are added or
removed directly inside it: a reasonable proxy for "last touched by a deploy", but not an
exact one. `-name` takes a glob, so if the basename of `SSH_REMOTE_TEMP_DIR` contains `*`,
`?` or `[`, more folders may match. Run it after `release`, in its own job that requires
the release job (see [CircleCI example](#circleci-example)).

**Live folder:** when `SSH_REMOTE_DIR` is set and its parent folder (trailing slash
ignored) is the parent of `SSH_REMOTE_TEMP_DIR`, `cleanup` adds
`! -name '<basename of SSH_REMOTE_DIR>' ! -name '<basename of SSH_REMOTE_DIR>_old_*'` to
the `find`. So with `SSH_REMOTE_TEMP_DIR=/var/www/app` and
`SSH_REMOTE_DIR=/var/www/app-live`, neither `app-live` nor the `app-live_old_<timestamp>`
copies kept by `KEEP_OLD=true` are removed, even though they match `app-*`. When
`SSH_REMOTE_DIR` is in another parent folder no exclusion is added, since it cannot match;
when it is unset, nothing is excluded besides the workspace folder, so set it for
`cleanup` if the live folder shares the staging parent. These exclusions are globs too: if
the basename of `SSH_REMOTE_DIR` contains `*`, `?` or `[`, more folders may be kept
(never fewer).

**Recommended layout:** keep both folders under a parent of their own, with names that
cannot match each other. It is not required, but it is clearer:

```bash
SSH_REMOTE_DIR=/srv/app/live
SSH_REMOTE_TEMP_DIR=/srv/app/staging   # workspace folders: /srv/app/staging-<id>
```

### Pitfalls

- **`upload` and a trailing slash on `SOURCE`** (rsync semantics): `SOURCE=dist/` uploads
  the folder's contents into the target folder, `SOURCE=dist` uploads the `dist` folder
  itself (as `<target folder>/dist`).
- **`link` with a relative `SOURCE`:** the link is created in staging and moves with it
  when `release` runs, so a relative `SOURCE` resolves against the link's final location.
  Use an absolute `SOURCE`.
- **`link` over a real folder:** if `DEPLOY_PATH` already exists as a real folder in
  staging (e.g. something was uploaded there), `ln -sfn` creates the link *inside* that
  folder instead of replacing it.
- **`build` in images without node:** `build` runs `npm run build` unless `BUILD_COMMAND`
  is set; set it or skip `build`.
- **Concurrent deploys:** two workflows deploying at once each get their own workspace
  folder, and whichever `release` runs last wins. Two releases in the same second share
  the `${SSH_REMOTE_DIR}_old_<timestamp>` name, so the second one's `rm -rf` deletes the
  first one's backup. Run deploys one at a time, e.g. with a CircleCI serial group or a
  branch filter.

### Variables

| Variable | Required | Default | Description |
|----------|----------|---------|---------|
| `SSH_PRIVATE_KEY` | yes, for `generate_key_file` | | Private key; literal `\n` is turned into newlines. |
| `SSH_KNOWN_HOSTS` | no | | known_hosts line(s) for the host (`\n` allowed). When set, ssh uses `StrictHostKeyChecking=yes` with `~/ssh_known_hosts`; when not set, host keys are not checked (`StrictHostKeyChecking=no`). |
| `SSH_USER` | yes, for remote actions | | Remote user. |
| `SSH_HOST` | yes, for remote actions | | Remote host. |
| `SSH_PORT` | no | `22` | Remote ssh port. |
| `SSH_REMOTE_TEMP_DIR` | yes, for remote actions | | Staging folder base path. |
| `SSH_REMOTE_DIR` | yes, for `copy_files` and `release` | | Live folder. Optional for `cleanup`, which then keeps it and its `_old_*` folders. |
| `CIRCLE_WORKFLOW_WORKSPACE_ID` | no | | Suffix of the workspace folder (set by CircleCI). |
| `DEPLOY_PATH` | no | | Path inside the workspace folder; for `link`, the link path. |
| `SOURCE` | yes, for `upload` and `link` | | Local path to upload (`upload`) or remote path the link points to (`link`). |
| `TARGET` | no | | `copy_files`: path inside the live folder to copy. `link`: link path when `DEPLOY_PATH` is not set. |
| `EXCLUDE_FROM` | no | | Local file of rsync exclude patterns for `upload`. |
| `BUILD_COMMAND` | no | `npm run build` | Build command for `build`. |
| `COMMAND` | yes, for `run` | | Command run in the target folder. It is sent as is, so the caller is responsible for its quoting. |
| `KEEP_OLD` | no | `false` | When `true`, `release` keeps the previous live folder. |
| `CLEANUP_MAX_AGE_MINUTES` | no | `1440` | `cleanup` removes the staging folders older than this many minutes; must be a non-negative integer. More recent folders are kept, since they may belong to a deploy that is still running. |

### CircleCI example

Copy the script into the CircleCI image:

```dockerfile
COPY --from=darthjee/scripts:<version> /home/scripts/sbin/deploy_frontend.sh /usr/local/sbin/
```

Then, in `.circleci/config.yml`, upload jobs run in parallel into one staging tree (they
share `CIRCLE_WORKFLOW_WORKSPACE_ID`), and a final job links the server-only files, runs
the migrations in staging and releases; a last job removes stale staging folders:

```yaml
jobs:
  upload-backend:
    docker:
      - image: <your-image>
    steps:
      - checkout
      - run: deploy_frontend.sh generate_key_file
      - run: SOURCE=build/backend/ EXCLUDE_FROM=deploy/exclude.txt deploy_frontend.sh upload
  upload-frontend:
    docker:
      - image: <your-image>
    steps:
      - checkout
      - run: deploy_frontend.sh generate_key_file
      - run: BUILD_COMMAND="yarn build" deploy_frontend.sh build
      - run: SOURCE=dist/ DEPLOY_PATH=public/admin/ deploy_frontend.sh upload
  release:
    docker:
      - image: <your-image>
    steps:
      - run: deploy_frontend.sh generate_key_file
      - run: SOURCE="$REMOTE_HOME/shared/.env" DEPLOY_PATH=config/.env deploy_frontend.sh link
      - run: COMMAND="$PHP_BIN bin/migrate" deploy_frontend.sh run
      - run: deploy_frontend.sh release
  cleanup:
    docker:
      - image: <your-image>
    steps:
      - run: deploy_frontend.sh generate_key_file
      - run: deploy_frontend.sh cleanup

workflows:
  deploy:
    jobs:
      - upload-backend
      - upload-frontend
      - release:
          requires:
            - upload-backend
            - upload-frontend
      - cleanup:
          requires:
            - release
```

`cleanup` runs in its own job so that a `cleanup` failure can be retried alone. A
re-run workflow inherits the original workflow's workspace
([Using workspaces](https://circleci.com/docs/guides/orchestrate/workspaces/)), and
`CIRCLE_WORKFLOW_WORKSPACE_ID` identifies that workspace
([Project values and variables](https://circleci.com/docs/reference/variables/)), so
"Rerun workflow from failed" keeps the same workspace folder. Had `cleanup` run in the
release job, the rerun would repeat the whole job and `release` would fail at its first
step, because the workspace folder has already been moved to the live folder. With a
separate job, only `cleanup` runs again.

The `SSH_*` variables (and `SSH_KNOWN_HOSTS`, to check the host key) come from the project
or context environment variables.

### Tests

The script is covered by a bash test suite (with `ssh` and `rsync` stubbed), run from the
repository with `bin/script.sh test scripts`.

## How to use

This image is not intended for standalone use, but rather as a base or complement for other Docker images, providing ready-to-use tools and utilities.

You can use the scripts directly in your Dockerfiles or during development, as needed by your project.

## Usage example

```dockerfile
FROM darthjee/scripts:latest as scripts
FROM <base_image> as base

# Base building

##### BUILD STEP #######

FROM base as builder
# build image

COPY --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

##### FINAL STEP #######
FROM base as builder

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/

COPY --from=scripts /home/scripts/sbin/check_spec /usr/local/sbin/


#Final building
```

## License

See the LICENSE file for more information.
