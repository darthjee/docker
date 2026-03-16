darthjee/ruby_node
==================

## About the image

The `darthjee/ruby_node` image is a Docker image built on top of `darthjee/ruby_331`. It extends the base Ruby image by adding **Node.js** (v20.x) and **npm**, enabling the use of front-end tooling such as **yarn**, **webpack**, and other Node-based build tools alongside Ruby.

This image is intended for development environments where both Ruby and front-end asset compilation are required.

## What is added

On top of everything provided by `darthjee/ruby_331`, this image installs:

- **Node.js** (v20.x) – JavaScript runtime for running front-end build tools.
- **npm** – Node package manager.
- **yarn** – JavaScript package manager for front-end dependencies.

## How to use

Reference this image in your `Dockerfile`:

```dockerfile
FROM darthjee/ruby_node:1.4.2
```

You can then run yarn or install your project-specific Node packages on top of the shared base:

```dockerfile
FROM darthjee/ruby_node:1.4.2

RUN yarn install
```

Or pull it directly:

```bash
docker pull darthjee/ruby_node:1.4.2
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/ruby_node` | Development environment with Ruby and Node.js |
| `darthjee/circleci_ruby_node` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_ruby_node` | Production-ready variant, stripped of development tooling |

## License

See the LICENSE file for more information.
