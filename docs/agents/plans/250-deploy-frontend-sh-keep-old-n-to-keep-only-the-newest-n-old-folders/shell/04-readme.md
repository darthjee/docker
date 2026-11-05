# README
Update `scripts/0.14.0/README.md` (`## deploy_frontend.sh` section), following `docs/agents/image-readme.md`:

- Actions table, `release` row: describe the three `KEEP_OLD` modes in short form.
- `#### release failure modes`: step 4 becomes "`rm -rf <old>` when `KEEP_OLD` is unset/`false`/`0`; with `KEEP_OLD=<n>`, remove all but the newest `n` `_old_<digits>` folders". Add a note that an invalid `KEEP_OLD` fails before step 1, with nothing touched.
- `#### Rollback`: replace "with `KEEP_OLD=true` they pile up until the caller prunes them" with the `KEEP_OLD=<n>` option (recommended), keeping `true` as "keep all, prune by hand".
- Variables table, `KEEP_OLD` row: `true`, `false`/`0`, or a number of folders to keep (counting the one created by this release).

## Files to Change
- `scripts/0.14.0/README.md` — `release` row, failure modes, rollback notes, `KEEP_OLD` variable row
