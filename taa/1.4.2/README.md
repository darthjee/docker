darthjee/taa
============

## About the image

The `darthjee/taa` image is a Docker image built on top of `darthjee/rails_yarn`. It extends the base Rails + Yarn image by pre-installing a curated set of **Rails gems** and **AngularJS packages** to speed up the development of Rails applications with an AngularJS front end.

## What is added

On top of everything provided by `darthjee/rails_yarn`, this image installs:

### Additional gems (Rails)

- **azeroth** (2.0.0) – Opinionated resource routing helpers for fast Rails API development.
- **tarquinn** (0.3.0) – Simplified redirect rules for Rails controllers.
- **jace** (0.1.1) – Ruby gem for managing event triggers with before/after handlers.
- **magicka** (1.1.0) – Form and input component helpers for Rails views.

### Additional front-end packages (via Yarn)

- **angular** (1.4.8) – AngularJS framework for building dynamic web applications.
- **angular-route** (1.4.8) – Official AngularJS routing module.
- **cyberhawk** (0.8.0) – Helpers for quickly creating AngularJS controllers and components.
- **johto** (^0.0.1) – Utility for quickly defining AngularJS routes.

## Pre-installed gems

Everything inherited from `darthjee/rails_yarn` plus the gems listed above.

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
- `azeroth` (2.0.0)
- `tarquinn` (0.3.0)
- `jace` (0.1.1)
- `magicka` (1.1.0)

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

Reference this image in your `Dockerfile`:

```dockerfile
FROM darthjee/taa:1.4.2
```

Projects can then install their own specific gems and packages on top of the shared base, taking advantage of Docker layer caching to speed up builds and CI pipelines.

```dockerfile
FROM darthjee/taa:1.4.2

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install
```

Or pull it directly:

```bash
docker pull darthjee/taa:1.4.2
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/taa` | Development environment with Rails, AngularJS gems and packages |
| `darthjee/circleci_taa` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_taa` | Production-ready variant, stripped of development and test gems |

## License

See the LICENSE file for more information.
