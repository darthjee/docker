darthjee/circleci_rails_yarn
============================

## About the image

The `darthjee/circleci_rails_yarn` image is a CircleCI-optimized Docker image built on top of `darthjee/circleci_ruby_node`. It is the CircleCI counterpart of `darthjee/rails_yarn`, extending the base CircleCI Ruby + Node image by adding **Yarn** and pre-installing a curated set of **front-end packages** and **Rails application gems**, providing a ready-to-use environment for running Rails application tests and front-end builds on circleci.com.

## What is added

On top of everything provided by `darthjee/circleci_ruby_node`, this image installs:

- **Yarn** (1.22.22) – JavaScript package manager, installed globally via npm.
- **telnet** – Network utility, useful for debugging connectivity in CI pipelines.

### Front-end packages (via Yarn)

The following Node packages are pre-installed:

- `underscore` (1.13.6) – Utility library for JavaScript.
- `bootstrap` (4.6.2) – CSS framework for responsive UI.
- `jquery` (3.6.1) – JavaScript library for DOM manipulation.
- `js-cookie` (2.2.1) – Lightweight JavaScript API for cookies.

## Pre-installed gems

The following gems are pre-installed in the image:

### Core

- `bundler` (2.6.8)
- `rake` (13.2.1)
- `darthjee-core_ext` (2.0.0)
- `sinclair` (3.0.0)

### Rails

- `rails` (7.2.2.1)
- `rack` (2.2.6.3)
- `puma` (6.0.0)
- `sass-rails` (6.0.0)
- `uglifier` (4.2.0)
- `nokogiri` (1.18.8)
- `turbolinks` (5.2.1)
- `newrelic_rpm` (8.12.0)
- `tzinfo-data` (1.2023.3)

### Development and test

- `pry` (0.14.2)
- `pry-nav` (1.0.0)
- `pry-rails` (0.3.9)
- `simplecov` (0.22.0)
- `yard` (0.9.37)
- `yardstick` (0.9.9)
- `zyra` (1.2.0)

### Development

- `rubycritic` (4.9.2)
- `reek` (6.4.0)
- `rubocop` (1.75.5)
- `rubocop-rspec` (3.6.0)
- `zonebie` (0.6.1)
- `web-console` (4.2.0)

### Test

- `factory_bot` (6.2.1)
- `rails-controller-testing` (1.0.5)
- `rspec` (3.13.0)
- `rspec-collection_matchers` (1.2.1)
- `rspec-core` (3.13.3)
- `rspec-expectations` (3.13.3)
- `rspec-mocks` (3.13.2)
- `rspec-rails` (8.0.0)
- `rspec-support` (3.13.2)
- `shoulda-matchers` (5.3.0)
- `timecop` (0.9.6)
- `webmock` (3.18.1)

## How to use

Reference this image in your `.circleci/config.yml` or `Dockerfile`:

```dockerfile
FROM darthjee/circleci_rails_yarn:1.0.1
```

Or use it directly in a CircleCI pipeline:

```yaml
jobs:
  test:
    docker:
      - image: darthjee/circleci_rails_yarn:1.0.1
    steps:
      - checkout
      - run: bundle install
      - run: yarn install
      - run: bundle exec rspec
```

Or pull it directly:

```bash
docker pull darthjee/circleci_rails_yarn:1.0.1
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/rails_yarn` | Development environment with Rails, Yarn and FE packages |
| `darthjee/circleci_rails_yarn` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_rails_yarn` | Production-ready variant, stripped of development and test gems |

## License

See the LICENSE file for more information.
