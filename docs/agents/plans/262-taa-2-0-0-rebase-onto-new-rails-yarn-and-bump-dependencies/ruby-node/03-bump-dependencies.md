# Bump dependencies
Gemfile (identical in all three images):

- `ruby '3.4.12'`, `gem 'bundler', '>= 4.0.24'`.
- Every gem also in `rails_yarn/2.0.0/home/Gemfile` takes exactly its version: e.g. `rails 7.2.4`, `puma 7.2.1`, `rack 3.2.8`, `rake 13.4.2`, `nokogiri 1.19.7`, `tzinfo-data 1.2026.6`, `yard 0.9.45`, `rubocop 1.92.2`, `rubocop-rspec 3.10.2`, `rubocop-rails 2.38.0`, `rubocop-rspec_rails 2.33.0`, `factory_bot 6.6.0`, `rspec-core 3.13.7`, `rspec-expectations 3.13.6`, `rspec-mocks 3.13.9`, `rspec-rails 8.1.0`, `rspec-support 3.13.8`, `timecop 0.9.11`, `webmock 3.34.0` (copy from the file, not this list).
- taa-only gems unchanged: `azeroth 2.2.0`, `darthjee-active_ext 1.4.0`, `jace 0.1.2`, `tarquinn 0.5.0`, `magicka 1.2.0`.

Regenerate `Gemfile.lock` inside a Ruby 3.4.12 container (e.g. `darthjee/rails_yarn:2.0.0` or `ruby:3.4.12`) with `bundle lock --update` then `bundle lock --add-platform x86_64-linux aarch64-linux`, and copy the same lock to all three images.

package.json (all three): `js-cookie` `3.0.7` → `3.0.8`. Keep `cyberhawk 0.8.0`, `johto ^0.0.1`, `angular`/`angular-route 1.8.3`, `underscore 1.13.8`, `bootstrap 4.6.2`, `jquery 3.7.1`, `yarn 1.22.22`.

## Files to Change
- `{,circleci_,production_}taa/2.0.0/home/Gemfile`
- `{,circleci_,production_}taa/2.0.0/home/Gemfile.lock`
- `{,circleci_,production_}taa/2.0.0/home/package.json`
