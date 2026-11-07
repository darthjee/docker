darthjee/circleci_ruby_3412
===========================

[![docker](https://img.shields.io/docker/v/darthjee/circleci_ruby_3412.svg?logo=docker&label=circleci_ruby_3412&sort=semver)](https://hub.docker.com/r/darthjee/circleci_ruby_3412)

## About the image

The `darthjee/circleci_ruby_3412` image is the CircleCI counterpart of [`darthjee/ruby_3412`](https://hub.docker.com/r/darthjee/ruby_3412). It is not built on top of the dev image: it is a parallel image built on the official `cimg/ruby:3.4.12` image, which already provides git and the usual CircleCI tooling. It is designed to run Ruby application tests on circleci.com, coming pre-installed with common gems and development utilities so that individual projects only need to install their own specific additions on top of it.

The image runs as the `circleci` user, with `/home/circleci/project` as its working directory, owned by `circleci`.

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
- `rubocop-rake`

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

This image is intended to be used as an executor for CircleCI pipelines in Ruby projects. Reference it in your `.circleci/config.yml` (see the available tags at https://hub.docker.com/r/darthjee/circleci_ruby_3412/tags):

```yaml
jobs:
  test:
    docker:
      - image: darthjee/circleci_ruby_3412:<version>
    steps:
      - checkout
      - run: bundle install
      - run: bundle exec rspec
```

It can also be used as a base in a `Dockerfile`:

```dockerfile
FROM darthjee/circleci_ruby_3412:<version>
```

Projects can then install their own specific gems on top of the shared base, taking advantage of the pre-installed gems to speed up CI pipelines.

## License

See the LICENSE file for more information.
