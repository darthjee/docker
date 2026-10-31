darthjee/production_ruby_node
=============================

## About the image

The `darthjee/production_ruby_node` image is the production counterpart of [`darthjee/ruby_node`](https://hub.docker.com/r/darthjee/ruby_node), without development dependencies. It is a parallel image built on top of [`darthjee/production_ruby_331`](https://hub.docker.com/r/darthjee/production_ruby_331), and adds **Node.js** and **npm** to support front-end asset compilation or server-side JavaScript execution in production environments.

The image runs as the `app` user (uid 1000), with `/home/app/app` as the working directory, owned by `app`.

## What is added

On top of everything provided by `darthjee/production_ruby_331`, this image installs:

- **Node.js** – JavaScript runtime, installed from NodeSource.
- **npm** – Node package manager.
- **ncat** – networking utility (e.g. to wait for services to be reachable).

## How to use

Reference this image in your production `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_ruby_node/tags), installing only the main dependencies:

```dockerfile
FROM darthjee/production_ruby_node:<version>

COPY --chown=app:app Gemfile Gemfile.lock package.json package-lock.json ./
RUN bundle config set without 'development test' && \
    bundle install && \
    npm install --omit=dev
```

## License

See the LICENSE file for more information.
