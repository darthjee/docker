# Bump the Gemfiles and regenerate the lock files
In `ruby_3412/1.0.0/home/Gemfile`:

- `ruby '3.3.1'` → `ruby '3.4.12'`.
- `gem 'bundler', '>= …'` → the Bundler version chosen in step 02.
- `activesupport` → the latest **7.2.x** patch (no 8.x).
- Every other gem → its latest release **within its current major** (e.g. `rubocop` 1.x, `rspec*` 3.x, `rubycritic` 5.x), as long as it supports Ruby 3.4.

Copy the same pins into the two counterpart Gemfiles. The three Gemfiles are identical today, so either copy the file, or run `bin/script.sh update_deps circleci_ruby_3412 ruby_3412` and `bin/script.sh update_deps production_ruby_3412 ruby_3412` once the three images are in `version` (step 05).

Regenerate each `Gemfile.lock` inside the matching base image, so platforms and native gems resolve for Ruby 3.4.12. For example:

```bash
docker run --rm -v "$PWD/ruby_3412/1.0.0/home:/app" -w /app ruby:3.4.12 \
  bash -c 'gem install bundler:<v> && bundle lock --update --add-platform x86_64-linux aarch64-linux'
```

For circleci use `cimg/ruby:3.4.12`. `BUNDLED WITH` should end up as the chosen Bundler version in all three lock files.

## Files to Change
- `ruby_3412/1.0.0/home/Gemfile`, `home/Gemfile.lock` — Ruby 3.4.12, gem bumps, new lock file.
- `circleci_ruby_3412/1.0.0/home/Gemfile`, `home/Gemfile.lock` — same pins, new lock file.
- `production_ruby_3412/1.0.0/home/Gemfile`, `home/Gemfile.lock` — same pins, new lock file.
