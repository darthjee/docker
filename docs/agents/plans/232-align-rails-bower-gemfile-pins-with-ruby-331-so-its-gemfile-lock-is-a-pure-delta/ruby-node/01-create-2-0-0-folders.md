# Create the 2.0.0 version folders
Create `rails_bower/2.0.0`, `circleci_rails_bower/2.0.0` and `production_rails_bower/2.0.0` from 1.6.0, for example with `bin/script.sh init rails_bower 2.0.0`. The `FROM` lines stay `darthjee/scripts:0.11.0` and the matching `*ruby_node:1.6.0` variant. Keep the bundler subtests as they are: plain `bundle check` for dev and circleci, and `BUNDLE_WITHOUT=development:test bundle check --gemfile=/home/app/app/Gemfile` for production.

## Files to Change
- `rails_bower/2.0.0/`, `circleci_rails_bower/2.0.0/`, `production_rails_bower/2.0.0/`: new version folders copied from 1.6.0
