# Bump dependencies
1. Replace each `2.0.0/home/Gemfile` with the exact contents of `taa/2.0.0/home/Gemfile`, keeping:
   - `ruby '3.4.12'`
   - bundler `>= 4.0.24`
   - every shared gem at taa 2.0.0's version: rails 7.2.4, puma 7.2.1, rack 3.2.8, rake 13.4.2, nokogiri 1.19.7, tzinfo-data 1.2026.6, yard 0.9.45, rubocop 1.92.2, rubocop-rspec 3.10.2, rubocop-rails 2.38.0, rubocop-rspec_rails 2.33.0, factory_bot 6.6.0, rspec-core 3.13.7, rspec-expectations 3.13.6, rspec-mocks 3.13.9, rspec-rails 8.1.0, rspec-support 3.13.8, timecop 0.9.11, webmock 3.34.0, and the rest unchanged from taa 2.0.0.
2. Append the taap-only gems after `observer`, in the main group, as in 1.7.0:
   - `gem 'danica',  '3.0.0'`
   - `gem 'gnuplot', '2.6.2'`
3. Regenerate `Gemfile.lock`:
   - Start from `taa/2.0.0/home/Gemfile.lock`, so that shared transitive gems match the base exactly.
   - Run `bundle lock` (e.g. inside `darthjee/taa:2.0.0`) to add danica, gnuplot and their dependencies.
   - Ensure the lock has both `x86_64-linux` and `aarch64-linux` platforms, as in taa 2.0.0.
4. Copy the same Gemfile and Gemfile.lock into all three variants, which stay identical.

## Files to Change
- `{,circleci_,production_}taap/2.0.0/home/Gemfile`
- `{,circleci_,production_}taap/2.0.0/home/Gemfile.lock`
