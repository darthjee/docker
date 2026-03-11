darthjee/circleci_ruby_331
==========================

## About the image

The `darthjee/circleci_ruby_331` image is a CircleCI-optimized Docker image built on top of the official `cimg/ruby:3.3.1` image. It is the CircleCI counterpart of `darthjee/ruby_331`, designed to run Ruby application tests on circleci.com. It comes pre-installed with common gems and development utilities so that individual projects only need to install their own specific additions on top of it.

## Pre-installed gems

The following gems are pre-installed in the image:

### Core

- `bundler`
- `rake`
- `sinclair`
- `activesupport`

### Development and test

- `pry`
- `pry-nav`
- `simplecov`
- `simplecov-html`
- `simplecov-lcov`
- `rubycritic`
- `yard`
- `yardstick`

### Development

- `reek`
- `rubocop`
- `rubocop-rspec`

### Test

- `rspec`
- `rspec-collection_matchers`
- `rspec-core`
- `rspec-expectations`
- `rspec-mocks`
- `rspec-support`

## Included scripts

The following helper scripts are available inside the image:

- `rubycritic.sh`: Runs RubyCritic on changed files to provide code quality reports for Ruby projects.
- `check_specs`: Runs automated tests based on configuration, supporting custom test file discovery.
- `check_readme.sh`: Verifies if the README contains a link to the correct RubyDoc documentation for the current gem version.
- `build_gem.sh`: Automates the process of building and releasing Ruby gems, ensuring version and tag consistency.

## How to use

This image is intended to be used as a base for CircleCI pipelines in Ruby projects. To build on top of it, reference it in your `.circleci/config.yml` or `Dockerfile`:

```dockerfile
FROM darthjee/circleci_ruby_331:1.1.0
```

Projects can then install their own specific gems on top of the shared base, taking advantage of Docker layer caching to speed up CI pipelines.

## License

See the LICENSE file for more information.
