darthjee/rails_gems
===================

## About the image

The `darthjee/rails_gems` image is a Docker image built on top of `darthjee/ruby_331`. It is designed to provide a shared foundation for developing Ruby gems that target the Rails ecosystem, coming pre-installed with Rails and its related gems as well as common development and test utilities, so that individual projects only need to install their own specific additions on top of it.

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

This image is intended to be used as a base for other Docker images in projects that develop Ruby gems for Rails. To build on top of it, reference it in your `Dockerfile`:

```dockerfile
FROM darthjee/rails_gems:2.0.0
```

Projects can then install their own specific gems on top of the shared base, taking advantage of Docker layer caching to speed up builds and CI pipelines.

## License

See the LICENSE file for more information.
