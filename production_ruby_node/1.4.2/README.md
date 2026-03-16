darthjee/production_ruby_node
==============================

## About the image

The `darthjee/production_ruby_node` image is a production-ready Docker image built on top of `darthjee/production_ruby_331`. It is the production counterpart of `darthjee/ruby_node`, extending the base production Ruby image with **Node.js** (v20.x) and **npm** to support front-end asset serving or server-side JavaScript execution in production environments.

Development and test dependencies are stripped out, keeping the image lightweight and suitable for production servers.

## What is added

On top of everything provided by `darthjee/production_ruby_331`, this image installs:

- **Node.js** (v20.x) – JavaScript runtime for running front-end build tools and serving assets.
- **npm** – Node package manager.
- **yarn** – JavaScript package manager for front-end dependencies.

## How to use

Reference this image in your production `Dockerfile`:

```dockerfile
FROM darthjee/production_ruby_node:1.4.2
```

Or pull it directly:

```bash
docker pull darthjee/production_ruby_node:1.4.2
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/ruby_node` | Development environment with Ruby and Node.js |
| `darthjee/circleci_ruby_node` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_ruby_node` | Production-ready variant, stripped of development tooling |

## License

See the LICENSE file for more information.
