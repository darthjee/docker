# Regenerate the lockfiles as a pure delta
For each variant, seed `home/Gemfile.lock` from the matching parent lockfile (`ruby_331`, `circleci_ruby_331` or `production_ruby_331`, version `1.2.0`; `ruby_node` installs no gems), the same way #221 did. Then run `bundle lock` inside the variant's parent image (`*ruby_node:1.6.0`) for the platforms x86_64-linux(-gnu) and aarch64-linux(-gnu). Keep `BUNDLED WITH` as it is: 4.0.23 for dev and production, 2.6.8 for circleci.

Check that every gem in the parent lockfile keeps exactly the same version in the new lock. The diff from the seed may only add gems, never change existing versions. If a parent gem still moves, go back to step 02 and fix the pin that causes it.

## Files to Change
- `rails_bower/2.0.0/home/Gemfile.lock`, `circleci_rails_bower/2.0.0/home/Gemfile.lock`, `production_rails_bower/2.0.0/home/Gemfile.lock`: regenerated lockfiles
