darthjee/production_rails_yarn
==============================

## About the image

The `darthjee/production_rails_yarn` image is a production-ready Docker image built on top of `darthjee/production_ruby_node`. It is the production counterpart of `darthjee/rails_yarn`, extending the base production Ruby + Node image by adding **Yarn** and pre-installing a curated set of **front-end packages** and **Rails application gems** suitable for running in production servers.

Development and test gems are excluded from the bundle, keeping the image lightweight. The image also ensures the `tmp/pids` directory is created and properly owned, as required for running Puma in production.

## What is added

On top of everything provided by `darthjee/production_ruby_node`, this image installs:

- **Yarn** (1.22.22) – JavaScript package manager, installed globally via npm.
- **telnet** – Network utility, useful for debugging connectivity in production.

### Front-end packages (via Yarn)

The following Node packages are pre-installed:

- `underscore` (1.13.6) – Utility library for JavaScript.
- `bootstrap` (4.6.2) – CSS framework for responsive UI.
- `jquery` (3.6.1) – JavaScript library for DOM manipulation.
- `js-cookie` (2.2.1) – Lightweight JavaScript API for cookies.

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

## How to use

Reference this image in your production `Dockerfile`:

```dockerfile
FROM darthjee/production_rails_yarn:1.0.1
```

Projects can then copy their application code and assets on top of the shared base:

```dockerfile
FROM darthjee/production_rails_yarn:1.0.1

COPY . /home/app/app/
RUN bundle exec rake assets:precompile
```

Or pull it directly:

```bash
docker pull darthjee/production_rails_yarn:1.0.1
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/rails_yarn` | Development environment with Rails, Yarn and FE packages |
| `darthjee/circleci_rails_yarn` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_rails_yarn` | Production-ready variant, stripped of development and test gems |

## License

See the LICENSE file for more information.
