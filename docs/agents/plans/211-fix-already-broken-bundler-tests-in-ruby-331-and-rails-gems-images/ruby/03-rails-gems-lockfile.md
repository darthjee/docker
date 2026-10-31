# Create rails_gems 2.1.2 with a deduplicated Gemfile and a Gemfile.lock
Run `bin/script.sh init rails_gems` after step 02. It creates `rails_gems/2.1.2` and `circleci_rails_gems/2.1.2` (there is no `production_rails_gems`) and bumps `version`. It also moves their `FROM` lines to `darthjee/ruby_331:1.1.2` / `darthjee/circleci_ruby_331:1.1.2`, because `version` already holds 1.1.2.

In both new `home/Gemfile`s, remove the second `gem 'rubocop-rspec', '3.9.0'` line from the `development` group. Keep the first one, aligned with the other entries.

Generate a `Gemfile.lock` for the deduplicated Gemfile the same way as step 02 (`ruby:3.3.1`, bundler 2.5.11, `bundle lock` plus `--add-platform x86_64-linux aarch64-linux`). The circleci builder installs `libsqlite3-dev`; locking needs no native compile, so no extra packages are needed for `bundle lock`. Copy the lockfile into both `home/` folders. The gems shared with `ruby_331` (`rake`, `sinclair`, `activesupport`, rspec, rubocop, ...) should resolve to the same versions as in step 02's lock. If they don't, check for conflicting constraints before continuing.

`rails_gems`' final stage also copies `home/*` into `/home/app/app`, so the lockfile ships in the image as well. This is expected.

## Files to Change
- `version` — `rails_gems`, `circleci_rails_gems` → `2.1.2` (via `init`).
- `rails_gems/2.1.2/**`, `circleci_rails_gems/2.1.2/**` — new version folders (via `init`), `FROM` on the 1.1.2 bases.
- `rails_gems/2.1.2/home/Gemfile`, `circleci_rails_gems/2.1.2/home/Gemfile` — remove the duplicate `rubocop-rspec`.
- `rails_gems/2.1.2/home/Gemfile.lock`, `circleci_rails_gems/2.1.2/home/Gemfile.lock` — new lockfile.
