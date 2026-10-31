darthjee/circleci_ruby_node
===========================

## About the image

The `darthjee/circleci_ruby_node` image is the CircleCI counterpart of [`darthjee/ruby_node`](https://hub.docker.com/r/darthjee/ruby_node). It is a parallel image, not built on top of `darthjee/ruby_node`: it is built on top of [`darthjee/circleci_ruby_331`](https://hub.docker.com/r/darthjee/circleci_ruby_331) (itself based on `cimg/ruby:3.3.1`), and adds **Node.js** and **npm** to support Node-based front-end tooling in CI pipelines.

This image is intended for use in CircleCI pipelines where both Ruby tests and front-end asset compilation or JavaScript testing are required.

The image runs as the `circleci` user, with `/home/circleci/project` as the working directory, owned by `circleci`.

## What is added

On top of everything provided by `darthjee/circleci_ruby_331`, this image installs:

- **Node.js** – JavaScript runtime, installed from NodeSource.
- **npm** – Node package manager.
- **ncat** – networking utility (e.g. to wait for services to be reachable).

## How to use

Use it as the executor image in your `.circleci/config.yml` (see the available tags at https://hub.docker.com/r/darthjee/circleci_ruby_node/tags):

```yaml
jobs:
  test:
    docker:
      - image: darthjee/circleci_ruby_node:<version>
    steps:
      - checkout
      - run: bundle install
      - run: npm install
      - run: bundle exec rspec
```

Or reference it in a `Dockerfile`:

```dockerfile
FROM darthjee/circleci_ruby_node:<version>
```

## License

See the LICENSE file for more information.
