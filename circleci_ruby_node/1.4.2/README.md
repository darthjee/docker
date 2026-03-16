darthjee/circleci_ruby_node
===========================

## About the image

The `darthjee/circleci_ruby_node` image is a CircleCI-optimized Docker image built on top of `darthjee/circleci_ruby_331`. It is the CircleCI counterpart of `darthjee/ruby_node`, extending the base CircleCI Ruby image with **Node.js** (v20.x) and **npm** to support front-end tooling such as **yarn** and **webpack** in CI pipelines.

This image is intended for use in CircleCI pipelines where both Ruby tests and front-end asset compilation or JavaScript testing are required.

## What is added

On top of everything provided by `darthjee/circleci_ruby_331`, this image installs:

- **Node.js** (v20.x) – JavaScript runtime for running front-end build tools.
- **npm** – Node package manager, used to install packages like `yarn`.

## How to use

Reference this image in your `.circleci/config.yml` or `Dockerfile`:

```dockerfile
FROM darthjee/circleci_ruby_node:1.4.2
```

Or use it directly in a CircleCI pipeline:

```yaml
jobs:
  test:
    docker:
      - image: darthjee/circleci_ruby_node:1.4.2
    steps:
      - checkout
      - run: yarn install
      - run: bundle exec rspec
```

Or pull it directly:

```bash
docker pull darthjee/circleci_ruby_node:1.4.2
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/ruby_node` | Development environment with Ruby and Node.js |
| `darthjee/circleci_ruby_node` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_ruby_node` | Production-ready variant, stripped of development tooling |

## License

See the LICENSE file for more information.
