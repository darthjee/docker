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
shell characters are safe, and the remote login shell may be a POSIX `sh`.

### Actions

| Action | What it does |
|--------|--------------|
| `generate_key_file` | Writes `SSH_PRIVATE_KEY` to `~/ssh_key` (mode 600), turning literal `\n` into newlines. When `SSH_KNOWN_HOSTS` is set, writes it the same way to `~/ssh_known_hosts`. |
| `build` | Runs `BUILD_COMMAND`. When `assets/images/` exists, copies it to `dist/assets/images/` and deletes the `*.pbm` files there. |
| `generate_folder` | Creates the target folder on the host (`mkdir -p`). |
| `copy_files` | Copies `$SSH_REMOTE_DIR/$TARGET` from the live folder into the target folder. |
| `upload` | Creates the target folder, then uploads `SOURCE` into it with `rsync -avz`, passing `--exclude-from="$EXCLUDE_FROM"` when set. |
| `link` | With `DEPLOY_PATH`: creates the link's parent folder and runs `ln -sfn "$SOURCE" <target folder>`, so `DEPLOY_PATH` is the link path inside staging. Without `DEPLOY_PATH` but with `TARGET`: `ln -sfn "$SOURCE" "$TARGET"`. With neither, exits `1`. |
| `run` | Runs `cd <target folder> && $COMMAND` on the host; the command's exit status is the action's. |
| `release` | Checks that the workspace folder exists (and fails before touching anything if it doesn't), moves the live folder aside to `${SSH_REMOTE_DIR}_old_<timestamp>` when it exists, moves the workspace folder to `SSH_REMOTE_DIR` and removes the old folder unless `KEEP_OLD=true`. |

### Variables

| Variable | Required | Default | Description |
|----------|----------|---------|---------|
| `SSH_PRIVATE_KEY` | yes, for `generate_key_file` | | Private key; literal `\n` is turned into newlines. |
| `SSH_KNOWN_HOSTS` | no | | known_hosts line(s) for the host (`\n` allowed). When set, ssh uses `StrictHostKeyChecking=yes` with `~/ssh_known_hosts`; when not set, host keys are not checked (`StrictHostKeyChecking=no`). |
| `SSH_USER` | yes, for remote actions | | Remote user. |
| `SSH_HOST` | yes, for remote actions | | Remote host. |
| `SSH_PORT` | no | `22` | Remote ssh port. |
| `SSH_REMOTE_TEMP_DIR` | yes, for remote actions | | Staging folder base path. |
| `SSH_REMOTE_DIR` | yes, for `copy_files` and `release` | | Live folder. |
| `CIRCLE_WORKFLOW_WORKSPACE_ID` | no | | Suffix of the workspace folder (set by CircleCI). |
| `DEPLOY_PATH` | no | | Path inside the workspace folder; for `link`, the link path. |
| `SOURCE` | yes, for `upload` and `link` | | Local path to upload (`upload`) or remote path the link points to (`link`). |
| `TARGET` | no | | `copy_files`: path inside the live folder to copy. `link`: link path when `DEPLOY_PATH` is not set. |
| `EXCLUDE_FROM` | no | | Local file of rsync exclude patterns for `upload`. |
| `BUILD_COMMAND` | no | `npm run build` | Build command for `build`. |
| `COMMAND` | yes, for `run` | | Command run in the target folder. It is sent as is, so the caller is responsible for its quoting. |
| `KEEP_OLD` | no | `false` | When `true`, `release` keeps the previous live folder. |

### CircleCI example

Copy the script into the CircleCI image:

```dockerfile
COPY --from=darthjee/scripts:<version> /home/scripts/sbin/deploy_frontend.sh /usr/local/sbin/
```

Then, in `.circleci/config.yml`, upload jobs run in parallel into one staging tree (they
share `CIRCLE_WORKFLOW_WORKSPACE_ID`), and a final job links the server-only files, runs
the migrations in staging and releases:

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

workflows:
  deploy:
    jobs:
      - upload-backend
      - upload-frontend
      - release:
          requires:
            - upload-backend
            - upload-frontend
```

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
