# Create the 0.11.0 version

Run `bin/script.sh init scripts 0.11.0`. It copies `scripts/0.10.0/` to `scripts/0.11.0/` and
sets `scripts=0.11.0` in `version` (there are no `circleci_scripts`/`production_scripts`
counterparts, so those are skipped). Check that `version` only changed on the `scripts=` line.

## Files to Change
- `scripts/0.11.0/` — new folder, copied from `0.10.0`.
- `version` — `scripts=0.11.0`.
