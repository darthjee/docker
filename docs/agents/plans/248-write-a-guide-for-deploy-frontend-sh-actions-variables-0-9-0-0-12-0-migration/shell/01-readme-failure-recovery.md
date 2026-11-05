# README: "Operates on" column and failure/recovery section

In `scripts/0.12.0/README.md`, section `## deploy_frontend.sh`:

1. **Actions table**: add an "Operates on" column: `local` for `generate_key_file`/`build`; the target folder (workspace folder + `DEPLOY_PATH`) for `generate_folder`, `copy_files`, `upload`, `link`, `run`; the **workspace folder** (`DEPLOY_PATH` ignored) → live folder for `release`; sibling `<basename>-*` folders of the workspace folder for `cleanup`. Also say outright in the `release` row that `DEPLOY_PATH` is ignored.
2. **New `### Failure and recovery` subsection** with:
   - the re-run safety table from the issue ("Re-run safety per action");
   - the `release` failure modes (the `&&` chain, and what each failing step leaves behind, including "no live folder" and "deploy succeeded but exit non-zero"). It must tell the reader to inspect the live, staging and `_old_*` folders before replaying any effectful action;
   - `KEEP_OLD=true` as a manual rollback: the exact ssh command with placeholders (move live aside, `mv` the newest `${SSH_REMOTE_DIR}_old_<timestamp>` back), that `_old_*` folders pile up (`cleanup` skips them), and that without `KEEP_OLD` the only rollback is redeploying the previous commit;
   - a `cleanup` failure does not mean the deploy failed.

## Files to Change
- `scripts/0.12.0/README.md` — actions table column; new failure and recovery subsection.
