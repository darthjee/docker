# Bump the Gemfile and regenerate the locks
Edit `rails_gems/3.0.0/home/Gemfile` per the issue's Solution §3 table: `ruby '3.4.12'`; Rails family `7.2.4`; `rake 13.4.2`; `rack 3.2.8`; `nokogiri 1.19.7`; `sqlite3 2.10.2`; `factory_bot 6.6.0`; `yard 0.9.45`; `rubocop 1.92.2`; `rubocop-rspec 3.10.2`; `rubocop-rails 2.38.0`; `rubocop-rspec_rails 2.33.0`; `rspec-core 3.13.7`; `rspec-expectations 3.13.6`; `rspec-mocks 3.13.9`; `rspec-support 3.13.8`; `rspec-rails 8.1.0`. Leave `pry`, `reek`, `simplecov` and the already-latest gems as they are. Keep `gem 'bundler', '>= 2.5.13'` or raise it to match the parent (`>= 4.0.24`), consistent with `ruby_3412`.

Regenerate the lock inside the parent image so it resolves on Ruby 3.4.12, keeping all four platforms:

```bash
docker run --rm -v "$PWD/rails_gems/3.0.0/home:/home/app/app" -w /home/app/app darthjee/ruby_3412:1.0.0 \
  bash -c 'rm -f Gemfile.lock && bundle lock --add-platform x86_64-linux x86_64-linux-gnu aarch64-linux aarch64-linux-gnu'
```

Check `PLATFORMS` lists `aarch64-linux`, `aarch64-linux-gnu`, `x86_64-linux`, `x86_64-linux-gnu`, and that `nokogiri`/`sqlite3` have `-x86_64-linux-gnu` and `-aarch64-linux-gnu` entries. Then mirror both files into `circleci_rails_gems/3.0.0/home/` (copy, or `bin/script.sh update_deps circleci_rails_gems rails_gems`) and confirm they are identical.

## Files to Change
- `rails_gems/3.0.0/home/Gemfile`, `rails_gems/3.0.0/home/Gemfile.lock`
- `circleci_rails_gems/3.0.0/home/Gemfile`, `circleci_rails_gems/3.0.0/home/Gemfile.lock`
