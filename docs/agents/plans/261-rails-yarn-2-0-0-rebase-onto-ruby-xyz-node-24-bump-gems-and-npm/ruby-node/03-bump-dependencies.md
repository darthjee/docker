# Bump gems and npm packages
Edit `rails_yarn/2.0.0/home/Gemfile`, then mirror it to the two counterparts (the three stay identical).

- `ruby '3.4.12'`, `gem 'bundler', '>= 4.0.24'`.
- Gems also in `rails_gems/3.0.0/home/Gemfile` or `ruby_3412/1.0.0/home/Gemfile` take exactly those versions: `rails` `7.2.4`, `rack`, `rake`, `nokogiri`, `sinclair`, `pry`, `pry-nav`, `simplecov*`, `rubycritic`, `yard`, `yardstick`, `reek`, `rubocop` + plugins, `factory_bot`, `rspec*`, `rails-controller-testing`.
- Every other gem: latest release compatible with Rails 7.2.4 / Ruby 3.4 (e.g. `puma`, `darthjee-core_ext`, `tzinfo-data`, `pry-rails`, `zyra`, `zonebie`, `web-console`, `shoulda-matchers`, `timecop`, `webmock`, `rspec-collection_matchers`).
- Keep `sass-rails`, `uglifier`, `turbolinks` (already latest) and `observer` (needed on Ruby 3.4).
- Regenerate `Gemfile.lock` inside a Ruby 3.4.12 container (e.g. `docker run --rm -v "$PWD/rails_yarn/2.0.0/home":/home/app/app darthjee/ruby_node:2.0.0 bundle lock --add-platform x86_64-linux aarch64-linux`, or `ruby_3412:1.0.0`), so the lock has `RUBY VERSION ruby 3.4.12`, `BUNDLED WITH 4.0.x` and both Linux platforms for native gems (nokogiri). Copy the same lock to the two counterparts.

`home/package.json` (all three): `js-cookie` `3.0.7` → `3.0.8`; leave `yarn 1.22.22`, `underscore 1.13.8`, `bootstrap 4.6.2`, `jquery 3.7.1`.

## Files to Change
- `rails_yarn/2.0.0/home/Gemfile`, `circleci_rails_yarn/2.0.0/home/Gemfile`, `production_rails_yarn/2.0.0/home/Gemfile`
- `rails_yarn/2.0.0/home/Gemfile.lock`, `circleci_rails_yarn/2.0.0/home/Gemfile.lock`, `production_rails_yarn/2.0.0/home/Gemfile.lock`
- `rails_yarn/2.0.0/home/package.json`, `circleci_rails_yarn/2.0.0/home/package.json`, `production_rails_yarn/2.0.0/home/package.json`
