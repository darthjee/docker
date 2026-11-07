darthjee/circleci_rails_gems
============================

[![docker](https://img.shields.io/docker/v/darthjee/circleci_rails_gems.svg?logo=docker&label=circleci_rails_gems&sort=semver)](https://hub.docker.com/r/darthjee/circleci_rails_gems)

## About the image

The `darthjee/circleci_rails_gems` image is the CircleCI counterpart of [`darthjee/rails_gems`](https://hub.docker.com/r/darthjee/rails_gems). It is not built on top of the dev image: it is a parallel image built on top of [`darthjee/circleci_ruby_3412`](https://hub.docker.com/r/darthjee/circleci_ruby_3412), which is based on the official `cimg/ruby:3.4.12` image and already provides git and the usual CircleCI tooling. It is designed to run tests for Ruby gems that target the Rails ecosystem on circleci.com, coming pre-installed with Rails 7.2 and its related gems as well as common development and test utilities, so that individual projects only need to install their own specific additions on top of it.

The image runs as the `circleci` user, with `/home/circleci/project` as its working directory, owned by `circleci`.

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

This image is intended to be used as an executor for CircleCI pipelines in projects that develop Ruby gems for Rails. Reference it in your `.circleci/config.yml` (see the available tags at https://hub.docker.com/r/darthjee/circleci_rails_gems/tags):

```yaml
jobs:
  test:
    docker:
      - image: darthjee/circleci_rails_gems:<version>
    steps:
      - checkout
      - run: bundle install
      - run: bundle exec rspec
```

It can also be used as a base in a `Dockerfile`:

```dockerfile
FROM darthjee/circleci_rails_gems:<version>
```

Projects can then install their own specific gems on top of the shared base, taking advantage of the pre-installed gems to speed up CI pipelines.

## License

See the LICENSE file for more information.
