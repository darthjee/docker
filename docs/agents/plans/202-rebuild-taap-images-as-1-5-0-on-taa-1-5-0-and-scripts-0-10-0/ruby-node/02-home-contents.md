# Rewrite home/ contents

For each of the three 1.5.0 variants:

- Replace `home/Gemfile` with the matching `taa` 1.5.0 Gemfile (`taa/1.5.0/home/Gemfile`, `circleci_taa/1.5.0/home/Gemfile`, `production_taa/1.5.0/home/Gemfile`; diff them, they're probably identical). Add these to the main group:
  ```ruby
  gem 'danica',  '3.0.0'
  gem 'gnuplot', '2.6.2'
  ```
  This drops the old `ruby '2.5.0'`, `bower-rails`, `newrelic_rpm` and the older pins.
- Delete `home/bower.json`: nothing runs Bower, and the `taa` chain doesn't install it.
- Delete `home/package.json`: it's identical to `taa` 1.5.0's, so a yarn step would add nothing.

## Files to Change
- `taap/1.5.0/home/Gemfile`, `circleci_taap/1.5.0/home/Gemfile`, `production_taap/1.5.0/home/Gemfile` — `taa` 1.5.0 Gemfile plus `danica` and `gnuplot`
- `{,circleci_,production_}taap/1.5.0/home/bower.json` — delete
- `{,circleci_,production_}taap/1.5.0/home/package.json` — delete
