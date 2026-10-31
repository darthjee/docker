# Create ruby_331 1.1.2 with a Gemfile.lock
Run `bin/script.sh init ruby_331`. It creates `ruby_331/1.1.2`, `circleci_ruby_331/1.1.2` and `production_ruby_331/1.1.2` and bumps all three to `1.1.2` in `version`.

Generate a `Gemfile.lock` for `ruby_331/1.1.2/home/Gemfile` inside a `ruby:3.3.1` container. Use the image's bundler version (`gem install bundler:2.5.11`), then run `bundle lock` and `bundle lock --add-platform x86_64-linux aarch64-linux`. Copy the same lockfile into `circleci_ruby_331/1.1.2/home/` and `production_ruby_331/1.1.2/home/`. All three Gemfiles are identical, so they share one resolution. The production build skips the dev/test groups through `bundle config set without`, and its test (from step 01) does the same.

Check that `bundle install` accepts the lock on each base. `cimg/ruby:3.3.1` uses bundler 2.6.8; a newer bundler reading an older `BUNDLED WITH` is fine. If the circleci build rewrites the lock, regenerate that copy with bundler 2.6.8 instead.

Update the version shown in each new README only where the README actually references a version (#173 removed hardcoded tags). Follow [docs/agents/image-readme.md](../../../image-readme.md).

## Files to Change
- `version` — `ruby_331`, `circleci_ruby_331`, `production_ruby_331` → `1.1.2` (via `init`).
- `ruby_331/1.1.2/**`, `circleci_ruby_331/1.1.2/**`, `production_ruby_331/1.1.2/**` — new version folders (via `init`).
- `ruby_331/1.1.2/home/Gemfile.lock`, `circleci_ruby_331/1.1.2/home/Gemfile.lock`, `production_ruby_331/1.1.2/home/Gemfile.lock` — new lockfile.
