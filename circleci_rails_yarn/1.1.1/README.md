darthjee/circleci_rails_yarn
============================

## About the image

The `darthjee/circleci_rails_yarn` image is the CircleCI counterpart of [`darthjee/rails_yarn`](https://hub.docker.com/r/darthjee/rails_yarn). It is a counterpart by name only: it is built on top of [`darthjee/circleci_ruby_331`](https://hub.docker.com/r/darthjee/circleci_ruby_331) (itself based on `cimg/ruby:3.3.1`), not on the development image. It adds **Node.js**, **npm** and **Yarn**, a pre-populated Yarn cache and a curated set of pre-installed **Rails application gems**, for running Rails test suites and front-end builds on circleci.com.

The image runs as the `circleci` user, with `/home/circleci/project` as its working directory.

## What is added

On top of everything provided by `darthjee/circleci_ruby_331`, this image installs:

- **Node.js** and **npm** (from NodeSource).
- **Yarn**, installed globally via npm.
- **ncat** and **telnet**, network utilities useful for debugging connectivity in CI pipelines.

## Pre-cached packages

The Yarn cache (`/usr/local/share/.cache/yarn/v6`) is pre-populated with the following front-end packages. They are only used when a project's `package.json` asks for them:

- `yarn`
- `underscore`
- `bootstrap`
- `jquery`
- `js-cookie`

## Pre-installed gems

The following gems are pre-installed in the image (under `/home/circleci/.rubygems`):

### Runtime

- `bundler`
- `darthjee-core_ext`
- `puma`
- `rack`
- `rake`
- `rails`
- `sass-rails`
- `uglifier`
- `nokogiri`
- `turbolinks`
- `sinclair`
- `tzinfo-data`
- `observer`

### Development and test

- `pry`
- `pry-nav`
- `pry-rails`
- `simplecov`
- `simplecov-html`
- `simplecov-lcov`
- `yard`
- `yardstick`
- `zyra`

### Development

- `rubycritic`
- `reek`
- `rubocop`
- `rubocop-rspec`
- `rubocop-factory_bot`
- `rubocop-rails`
- `rubocop-rake`
- `rubocop-rspec_rails`
- `zonebie`
- `web-console`

### Test

- `factory_bot`
- `rails-controller-testing`
- `rspec`
- `rspec-collection_matchers`
- `rspec-core`
- `rspec-expectations`
- `rspec-mocks`
- `rspec-rails`
- `rspec-support`
- `shoulda-matchers`
- `timecop`
- `webmock`

## How to use

Use the image as a CircleCI executor in your `.circleci/config.yml` (see the available tags at https://hub.docker.com/r/darthjee/circleci_rails_yarn/tags):

```yaml
jobs:
  test:
    docker:
      - image: darthjee/circleci_rails_yarn:<version>
    steps:
      - checkout
      - run: bundle install
      - run: yarn install
      - run: bundle exec rspec
```

Gems and packages already in the image are reused, so `bundle install` and `yarn install` only fetch what the project adds.

## License

See the LICENSE file for more information.
