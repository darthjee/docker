darthjee/circleci_rails_yarn
============================

## About the image

The `darthjee/circleci_rails_yarn` image is the CircleCI counterpart of [`darthjee/rails_yarn`](https://hub.docker.com/r/darthjee/rails_yarn). It is a parallel image, not built on top of `darthjee/rails_yarn`: it is built on top of [`darthjee/circleci_ruby_331`](https://hub.docker.com/r/darthjee/circleci_ruby_331) (itself based on `cimg/ruby:3.3.1`). It adds **Node.js**, **npm** and **Yarn**, pre-caches a set of front-end packages and pre-installs the gems commonly used by Ruby on Rails applications, providing a ready-to-use environment for running Rails application tests and front-end builds on circleci.com.

The image runs as the `circleci` user, with `/home/circleci/project` as the working directory, owned by `circleci`.

## What is added

On top of everything provided by `darthjee/circleci_ruby_331`, this image installs:

- **Node.js** – JavaScript runtime, installed from NodeSource.
- **npm** – Node package manager.
- **Yarn** – JavaScript package manager, installed globally via npm.
- **ncat** and **telnet** – networking utilities, useful for checking connectivity to other services.

## Pre-cached packages

The following packages are pre-cached in `/home/circleci/.cache/yarn/v6/`, yarn's default cache directory for the `circleci` user. They are not installed into any `node_modules`; they are used when a project's `package.json` asks for them and `yarn install` is run.

- `yarn`
- `underscore`
- `bootstrap`
- `jquery`
- `js-cookie`

> **Note:** The pre-cached `js-cookie` is version 3, a major upgrade with API changes (for example, `Cookies.getJSON` was removed); see the [js-cookie 3 migration notes](https://github.com/js-cookie/js-cookie/releases/tag/v3.0.0) before upgrading a project that relies on the 2.x API. The pre-cached `jquery` is version 3.7.

## Pre-installed gems

The following gems are pre-installed in the image, on top of the ones provided by `darthjee/circleci_ruby_331`:

### Core

- `bundler`
- `rake`
- `darthjee-core_ext`
- `sinclair`
- `observer`

### Rails

- `rails`
- `rack`
- `puma`
- `sass-rails`
- `uglifier`
- `nokogiri`
- `turbolinks`
- `tzinfo-data`

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

Use it as the executor image in your `.circleci/config.yml` (see the available tags at https://hub.docker.com/r/darthjee/circleci_rails_yarn/tags):

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

Or reference it in a `Dockerfile`:

```dockerfile
FROM darthjee/circleci_rails_yarn:<version>
```

## License

See the LICENSE file for more information.
