darthjee/ruby_node
==================

## About the image

The `darthjee/ruby_node` image is a Docker image built on top of [`darthjee/ruby_331`](https://hub.docker.com/r/darthjee/ruby_331). It extends the base Ruby image by adding **Node.js** and **npm**, enabling the use of Node-based front-end tooling alongside Ruby.

This image is intended for development environments where both Ruby and front-end asset compilation are required.

The image runs as the `app` user (uid 1000), with `/home/app/app` as the working directory, owned by `app`.

## What is added

On top of everything provided by `darthjee/ruby_331`, this image installs:

- **Node.js** – JavaScript runtime, installed from NodeSource.
- **npm** – Node package manager.
- **ncat** – networking utility (e.g. to wait for services to be reachable).

## How to use

Reference this image in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/ruby_node/tags):

```dockerfile
FROM darthjee/ruby_node:<version>
```

You can then install your project-specific gems and Node packages on top of the shared base:

```dockerfile
FROM darthjee/ruby_node:<version>

COPY --chown=app:app Gemfile Gemfile.lock package.json package-lock.json ./
RUN bundle install && npm install
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/ruby_node` | Development environment with Ruby and Node.js |
| `darthjee/circleci_ruby_node` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_ruby_node` | Production-ready variant, stripped of development tooling |

## License

See the LICENSE file for more information.
