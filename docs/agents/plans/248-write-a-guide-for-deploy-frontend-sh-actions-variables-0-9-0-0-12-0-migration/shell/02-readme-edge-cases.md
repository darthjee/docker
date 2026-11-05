# README: edge cases, gotchas and the CircleCI example

In `scripts/0.12.0/README.md`, section `## deploy_frontend.sh`:

1. **Correct the `cleanup` claim**: it does not "never remove" the live and `_old_*` folders when their names collide. Add the hard rule (`SSH_REMOTE_DIR` and `${SSH_REMOTE_DIR}_old_*` must not match `<basename of SSH_REMOTE_TEMP_DIR>-*` in the same parent folder), a safe layout example (`/srv/app/live` + `/srv/app/staging`), and a reference to #249.
2. **Edge cases and gotchas** (in the relevant action/variable rows, or a short `### Pitfalls` list):
   - remote paths are single-quoted, so `~` and globs are not expanded remotely: use absolute paths;
   - `$HOME` must be writable (`generate_key_file`);
   - `copy_files` doesn't create the target folder: run `generate_folder` or `upload` first;
   - a trailing slash on `SOURCE` changes what `upload` sends (rsync semantics);
   - `link`: use an absolute `SOURCE`; if `DEPLOY_PATH` is already a real folder, the link is created inside it;
   - concurrent deploys: last `release` wins, same-second `_old_<timestamp>` collision; recommend serializing deploys.
3. **CircleCI example**: move `deploy_frontend.sh cleanup` out of the `release` job into its own `cleanup` job that `requires` the release job, and add it to the workflow. Explain why: rerun-from-failed keeps `CIRCLE_WORKFLOW_WORKSPACE_ID`, so re-running a combined job would fail at `release`. Confirm and cite the CircleCI docs (see the Notes in `shell.md`). Also update the `### Cleanup` subsection's "run it after `release`, as the last step of the release job" wording.

## Files to Change
- `scripts/0.12.0/README.md` — `cleanup` description and Cleanup subsection, pitfalls, CircleCI example.
