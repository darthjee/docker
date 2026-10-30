# Build, test and record evidence

1. `bin/script.sh build taap`: all three images must build on amd64.
2. `bin/script.sh test taap`: all three test suites must pass.
3. Negative check (don't commit it): temporarily remove `gem 'danica'` from one variant's Gemfile, or build an image without the bundle `COPY`, and confirm `bin/script.sh test` fails. Then revert.
4. In each image, run `gem list | grep -E 'danica|gnuplot'`. For `production_taap`, also confirm that development and test gems (e.g. `rspec`, `rubocop`) are absent.
5. Put the outputs in the PR description: build/test summaries, the negative check, the `gem list` lines. Add the backward-compatibility notes from the plan, and `Closes #197`, `Closes #199`, `Closes #200`.

## Files to Change
- None (verification only)
