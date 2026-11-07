darthjee/rails_gems
===================

[![docker](https://img.shields.io/docker/v/darthjee/rails_gems.svg?logo=docker&label=rails_gems&sort=semver)](https://hub.docker.com/r/darthjee/rails_gems)

## About the image

The `darthjee/rails_gems` image is a Docker image built on top of [`darthjee/ruby_3412`](https://hub.docker.com/r/darthjee/ruby_3412), which is itself based on the official `ruby:3.4.12` image. It is designed to provide a shared foundation for developing Ruby gems that target the Rails ecosystem, coming pre-installed with Rails 7.2 and its related gems as well as common development and test utilities, so that individual projects only need to install their own specific additions on top of it.

The image runs as the `app` user (uid 1000), with `/home/app/app` as its working directory, owned by `app`. The image's `Gemfile` and `Gemfile.lock` are available in that directory.

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
- `sqlite3`

### Development and test

- `factory_bot`
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
- `rubocop-factory_bot`
- `rubocop-rails`
- `rubocop-rake`
- `rubocop-rspec_rails`

### Test

- `rspec`
- `rspec-core`
- `rspec-expectations`
- `rspec-mocks`
- `rspec-rails`
- `rspec-support`
- `rails-controller-testing`

## How to use

This image is intended to be used as a base for other Docker images in projects that develop Ruby gems for Rails. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/rails_gems/tags):

```dockerfile
FROM darthjee/rails_gems:<version>
```

Projects can then install their own specific gems on top of the shared base, taking advantage of Docker layer caching to speed up builds and CI pipelines.

## License

See the LICENSE file for more information.
