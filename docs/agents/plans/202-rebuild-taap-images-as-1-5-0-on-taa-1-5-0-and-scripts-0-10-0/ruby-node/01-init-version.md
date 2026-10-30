# Create the 1.5.0 version folders

Run `bin/script.sh init taap 1.5.0`. It copies `taap/1.4.2`, `circleci_taap/1.4.2` and `production_taap/1.4.2` to `1.5.0`, sets `taap`, `circleci_taap` and `production_taap` to `1.5.0` in `version`, and rewrites each `FROM darthjee/<img>:<tag>` to the version in `version`:

- `taa:1.4.2` → `taa:1.5.0` (and the same for `circleci_taa` and `production_taa`)
- `scripts:0.4.3` → `scripts:0.10.0`

Check the resulting `FROM` lines and `version` entries. Fix them by hand if `init` didn't produce exactly these.

## Files to Change
- `version` — `taap`, `circleci_taap` and `production_taap` set to `1.5.0`
- `taap/1.5.0/`, `circleci_taap/1.5.0/`, `production_taap/1.5.0/` — new folders copied from 1.4.2
