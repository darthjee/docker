darthjee/circleci_rails_gems
============================

## About the image

The `darthjee/circleci_rails_gems` image is a CircleCI-optimized Docker image built on top of `darthjee/circleci_ruby_331`. It is the CircleCI counterpart of `darthjee/rails_gems`, designed to run tests for Ruby gems that target the Rails ecosystem on circleci.com. It comes pre-installed with Rails and its related gems as well as common development and test utilities, so that individual projects only need to install their own specific additions on top of it.

## Pre-installed gems

The following gems are pre-installed in the image:

### Core

- `bundler`
- `rake`
- `sinclair`

### Rails

- `activesupport`
- `actionpack`
- `actionview`
- `activerecord`
- `rack`
- `rails`
- `nokogiri`
- `rails-controller-testing`
- `sqlite3`

### Development and test

- `factory_bot`
- `pry`
- `pry-nav`
- `simplecov`
- `rubycritic`
- `yard`
- `yardstick`

### Development

- `reek`
- `rubocop`
- `rubocop-rspec`

### Test

- `minitest`
- `rspec`
- `rspec-core`
- `rspec-expectations`
- `rspec-mocks`
- `rspec-rails`
- `rspec-support`

## How to use

This image is intended to be used as a base for CircleCI pipelines in projects that develop Ruby gems for Rails. To build on top of it, reference it in your `.circleci/config.yml` or `Dockerfile`:

```dockerfile
FROM darthjee/circleci_rails_gems:2.1.0
```

Projects can then install their own specific gems on top of the shared base, taking advantage of Docker layer caching to speed up CI pipelines.

## License

See the LICENSE file for more information.
