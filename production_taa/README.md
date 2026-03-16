darthjee/production_taa
=======================

## About the image

The `darthjee/production_taa` image is a production-ready Docker image built on top of `darthjee/production_rails_yarn`. It is the production counterpart of `darthjee/taa`, extending the base production Rails + Yarn image by pre-installing a curated set of **Rails gems** and **AngularJS packages** suitable for running in production servers.

Development and test gems are excluded from the bundle, keeping the image lightweight.

## What is added

On top of everything provided by `darthjee/production_rails_yarn`, this image installs:

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

Only production gems are installed. Development and test groups are excluded.

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

## How to use

Reference this image in your production `Dockerfile`:

```dockerfile
FROM darthjee/production_taa:1.4.2
```

Projects can then copy their application code and assets on top of the shared base:

```dockerfile
FROM darthjee/production_taa:1.4.2

COPY . /home/app/app/
RUN bundle exec rake assets:precompile
```

Or pull it directly:

```bash
docker pull darthjee/production_taa:1.4.2
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/taa` | Development environment with Rails, AngularJS gems and packages |
| `darthjee/circleci_taa` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_taa` | Production-ready variant, stripped of development and test gems |

## License

See the LICENSE file for more information.
