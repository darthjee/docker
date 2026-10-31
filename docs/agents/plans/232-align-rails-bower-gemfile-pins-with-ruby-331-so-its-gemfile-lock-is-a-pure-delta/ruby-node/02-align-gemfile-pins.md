# Align the Gemfile pins with ruby_331
In all three 2.0.0 `home/Gemfile`s, which are identical today, change the conflicting pins to the versions in `ruby_331/1.2.0/home/Gemfile`:

- `rails` 7.0.4.3 → 7.2.2.1, which matches `activesupport 7.2.2.1`
- `rake` 13.1.0 → 13.2.1
- `sinclair` 2.1.1 → 3.1.0
- `yard` 0.9.36 → 0.9.38
- `rubycritic` 4.9.1 → 5.0.0
- `reek` 6.1.4 → 6.5.0
- `rubocop` 1.59.0 → 1.85.1
- `rubocop-rspec` 2.29.2 → 3.9.0
- `rspec` 3.12.0 → 3.13.2, `rspec-core` → 3.13.6, `rspec-expectations` → 3.13.5, `rspec-mocks` → 3.13.8, `rspec-support` → 3.13.7, `rspec-collection_matchers` 1.2.0 → 1.2.1

These also fix the transitive ones: rubocop-ast, parser and unicode-display_width. Then bump only the pins this forces, such as `rspec-rails` to a 7.x that supports Rails 7.2, or `web-console`/`rails-controller-testing` if resolution or the tests need it. Keep the three Gemfiles identical.

## Files to Change
- `rails_bower/2.0.0/home/Gemfile`, `circleci_rails_bower/2.0.0/home/Gemfile`, `production_rails_bower/2.0.0/home/Gemfile`: aligned pins
