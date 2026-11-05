# Create scripts 0.14.0
Run `bin/script.sh init scripts` to scaffold `scripts/0.14.0` from 0.13.0 (0.13.0 is already published, so it must not be changed). Make sure the root `version` file reads `scripts=0.14.0` (update it if `init` did not). Commit this scaffold on its own, as in #249 (`chore(scripts): Create scripts 0.14.0 from 0.13.0`).

## Files to Change
- `scripts/0.14.0/**` — new version folder copied from 0.13.0
- `version` — `scripts=0.14.0`
