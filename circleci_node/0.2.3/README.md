darthjee/circleci_node
======================

## About the image

The `darthjee/circleci_node` image is a CircleCI-optimized Docker image with Node.js 22, built on top of the `cimg/node` image. It is the CircleCI counterpart of [`darthjee/node`](https://hub.docker.com/r/darthjee/node), designed to run tests for Node.js projects on circleci.com; both images pre-cache the same packages.

Its working directory is `/home/circleci/project`.

The `cimg/node` base already provides yarn, npm, git and the usual CircleCI tooling.

The image ships a warm yarn cache: a set of commonly used packages is pre-cached, so that when a project's `yarn install` asks for them they are resolved from the cache instead of being downloaded.

## Pre-cached packages

The following packages are pre-cached in the global yarn cache (`/usr/local/share/.cache/yarn/v6/`). They are not installed into any `node_modules`; they are used when a project's `package.json` asks for them and `yarn install` is run.

### Dependencies

- `express`
- `underscore`

### Development

- `express-generator`
- `sass`

### Linting

- `eslint`
- `eslint-config-standard`
- `eslint-plugin-complexity`
- `eslint-plugin-import`
- `eslint-plugin-jasmine`
- `eslint-plugin-n`
- `eslint-plugin-promise`
- `eslint-plugin-react`
- `eslint-plugin-react-hooks`

### Test and quality

- `jasmine`
- `nyc`
- `plato`

## How to use

This image is intended to be used in CircleCI pipelines of Node.js projects (see the available tags at https://hub.docker.com/r/darthjee/circleci_node/tags).

1. As the CircleCI job executor image, in your `.circleci/config.yml`:

   ```yaml
   jobs:
     test:
       docker:
         - image: darthjee/circleci_node:<version>
       steps:
         - checkout
         - run: yarn install
         - run: yarn test
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_node:<version>

   COPY package.json /home/circleci/project/
   RUN yarn install
   ```

In both cases, `yarn install` resolves the pre-cached packages from the warm yarn cache instead of downloading them, which speeds up CI pipelines.

## License

See the LICENSE file for more information.
