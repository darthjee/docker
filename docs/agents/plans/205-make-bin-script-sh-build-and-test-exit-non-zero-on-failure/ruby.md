# Ruby Plan: Make bin/script.sh build and test exit non-zero on failure

Main plan: [plan.md](plan.md)

## Shared contracts

Relies on the architect's new `bin/image.sh test` (always runs `/home/test/test.sh`, returns its status) and on `test/` being excluded from the release skip check, so this is a same-version fix: no `bin/script.sh init`. Uses the canonical `test/test.sh` from [plan.md](plan.md#shared-contracts). Report already-broken images back to the architect; don't fix them here.

## Implementation Steps

### Step 1 — Replace test.sh
Overwrite `test/test.sh` with the canonical script in the 5 current version folders listed below (keep it executable).

### Step 2 — Run the tests
With `DOCKER_ID_USER=darthjee`, run `bin/script.sh test ruby_331` and `bin/script.sh test rails_gems` (build or pull the images first if needed). Confirm a failing subtest now makes the command exit non-zero (e.g. temporarily add a `subtests/zz_fail.sh` with `exit 1`, then remove it). For each image whose real subtests fail, report the image, the subtest and the output to the architect.

## Files to Change
- `ruby_331/1.1.1/test/test.sh`
- `circleci_ruby_331/1.1.1/test/test.sh`
- `production_ruby_331/1.1.1/test/test.sh`
- `rails_gems/2.1.1/test/test.sh`
- `circleci_rails_gems/2.1.1/test/test.sh`

## Notes
- Don't touch subtests to make them pass. Broken subtests go into follow-up issues.
