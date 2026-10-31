darthjee/rails_yarn
===================

## About the image

The `darthjee/rails_yarn` image is a Docker image built on top of [`darthjee/ruby_331`](https://hub.docker.com/r/darthjee/ruby_331). It adds **Node.js**, **npm** and **Yarn**, pre-caches a set of front-end packages and pre-installs the gems commonly used by Ruby on Rails applications, providing a ready-to-use development environment for Rails applications with front-end asset compilation.

The image runs as the `app` user (uid 1000), with `/home/app/app` as the working directory, owned by `app`.

## What is added

On top of everything provided by `darthjee/ruby_331`, this image installs:

- **Node.js** – JavaScript runtime, installed from NodeSource.
- **npm** – Node package manager.
- **Yarn** – JavaScript package manager, installed globally via npm.
- **ncat** and **telnet** – networking utilities, useful for checking connectivity to other services.

## Pre-cached packages

The following packages are pre-cached in the global yarn cache (`/usr/local/share/.cache/yarn/v6/`). They are not installed into any `node_modules`; they are used when a project's `package.json` asks for them and `yarn install` is run.

- `yarn`
- `underscore`
- `bootstrap`
- `jquery`
- `js-cookie`

> **Note:** The pre-cached `js-cookie` is version 3, a major upgrade with API changes (for example, `Cookies.getJSON` was removed); see the [js-cookie 3 migration notes](https://github.com/js-cookie/js-cookie/releases/tag/v3.0.0) before upgrading a project that relies on the 2.x API. The pre-cached `jquery` is version 3.7.

## Pre-installed gems

The following gems are pre-installed in the image, on top of the ones provided by `darthjee/ruby_331`:

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

Reference this image in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/rails_yarn/tags):

```dockerfile
FROM darthjee/rails_yarn:<version>
```

Projects can then install their own specific gems and packages on top of the shared base, taking advantage of Docker layer caching to speed up builds and CI pipelines:

```dockerfile
FROM darthjee/rails_yarn:<version>

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=app:app package.json yarn.lock ./
RUN yarn install
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/rails_yarn` | Development environment with Rails, Yarn and front-end packages |
| `darthjee/circleci_rails_yarn` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_rails_yarn` | Production-ready variant, stripped of development and test gems |

## License

See the LICENSE file for more information.
