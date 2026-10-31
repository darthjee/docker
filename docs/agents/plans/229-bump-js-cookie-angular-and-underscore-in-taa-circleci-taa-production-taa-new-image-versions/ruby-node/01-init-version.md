# Create the 1.7.0 version folders
After #228 is merged into the branch (so `version` has `rails_yarn=1.3.0`, `circleci_rails_yarn=1.3.0` and `production_rails_yarn=1.3.0`), run `bin/script.sh init taa 1.7.0`. It copies `1.6.1` to `1.7.0` for all three variants, sets `taa=1.7.0`, `circleci_taa=1.7.0` and `production_taa=1.7.0` in `version`, and rewrites the `FROM` lines from the `version` file.

Check that each new Dockerfile has `FROM darthjee/scripts:0.11.0` and `FROM darthjee/<variant>rails_yarn:1.3.0`. Don't edit 1.6.1.

## Files to Change
- `taa/1.7.0/**`, `circleci_taa/1.7.0/**`, `production_taa/1.7.0/**` — new folders copied from 1.6.1
- `taa/1.7.0/Dockerfile`, `circleci_taa/1.7.0/Dockerfile`, `production_taa/1.7.0/Dockerfile` — `FROM *rails_yarn:1.3.0`
- `version` — `taa=1.7.0`, `circleci_taa=1.7.0`, `production_taa=1.7.0`
