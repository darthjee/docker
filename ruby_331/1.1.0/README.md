darthjee/ruby_331
=================

## About the image

The `darthjee/ruby_331` image is a base Docker image built on top of the official `ruby:3.3.1` image. It is designed to be a shared foundation for various Ruby projects, coming pre-installed with common gems and development utilities so that individual projects only need to install their own specific additions on top of it.

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
- `check_gems.sh`: Checks for missing or outdated Ruby gems and can upgrade all gems as needed.
- `check_specs`: Runs automated tests based on configuration, supporting custom test file discovery.

## How to use

This image is intended to be used as a base for other Docker images in Ruby projects. To build on top of it, reference it in your `Dockerfile`:

```dockerfile
FROM darthjee/ruby_331:1.0.2
```

Projects can then install their own specific gems on top of the shared base, taking advantage of Docker layer caching to speed up builds and CI pipelines.

## License

See the LICENSE file for more information.
