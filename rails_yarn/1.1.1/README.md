darthjee/rails_yarn
===================

## About the image

The `darthjee/rails_yarn` image is a development environment for Ruby on Rails applications that compile front-end assets. It is built on top of [`darthjee/ruby_331`](https://hub.docker.com/r/darthjee/ruby_331) and adds **Node.js**, **npm** and **Yarn**, a pre-populated Yarn cache and a curated set of pre-installed **Rails application gems**.

The image runs as the `app` user (uid 1000), with `/home/app/app` as its working directory.

## What is added

On top of everything provided by `darthjee/ruby_331`, this image installs:

- **Node.js** and **npm** (from NodeSource).
- **Yarn**, installed globally via npm.
- **ncat** and **telnet**, network utilities useful for debugging connectivity.

## Pre-cached packages

The Yarn cache (`/usr/local/share/.cache/yarn/v6`) is pre-populated with the following front-end packages. They are only used when a project's `package.json` asks for them:

- `yarn`
- `underscore`
- `bootstrap`
- `jquery`
- `js-cookie`

## Pre-installed gems

The following gems are pre-installed in the image:

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

Reference this image in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/rails_yarn/tags):

```dockerfile
FROM darthjee/rails_yarn:<version>

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install
```

Projects install their own gems and packages on top of the shared base. Gems and packages already in the image are reused, which speeds up builds and CI pipelines.

## Variants

| Image | Purpose |
|---|---|
| `darthjee/rails_yarn` | Development environment with Rails, Yarn and front-end packages |
| `darthjee/circleci_rails_yarn` | CircleCI variant for running CI pipelines |
| `darthjee/production_rails_yarn` | Production variant, without development and test gems |

## License

See the LICENSE file for more information.
