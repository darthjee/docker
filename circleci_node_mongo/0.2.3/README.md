darthjee/circleci_node_mongo
============================

## About the image

The `darthjee/circleci_node_mongo` image is a CircleCI-optimized Docker image with Node.js 22 and the MongoDB command-line tools. It is built on top of [`darthjee/circleci_node`](https://hub.docker.com/r/darthjee/circleci_node), which is itself built on the `cimg/node` image. It is the CircleCI counterpart of [`darthjee/node_mongo`](https://hub.docker.com/r/darthjee/node_mongo) by name only (it is not built on the dev image), designed to run tests for Node.js + MongoDB projects on circleci.com.

Its working directory is `/home/circleci/project`, and it runs as the `circleci` user.

The `cimg/node` base already provides yarn, npm, git and the usual CircleCI tooling.

The image inherits the base image's warm yarn cache: a set of commonly used packages is pre-cached, so that when a project's `yarn install` asks for them they are resolved from the cache instead of being downloaded.

## What is added

On top of [`darthjee/circleci_node`](https://hub.docker.com/r/darthjee/circleci_node), the image adds:

- `mongosh` (the MongoDB Shell)
- MongoDB Database Tools (`mongodump`, `mongorestore`, `mongoimport`, `mongoexport`, `mongostat`, `mongotop`, ...)

The final user is switched from `root` to `circleci`.

## Pre-cached packages

The following packages are pre-cached by the base image in the global yarn cache (`/usr/local/share/.cache/yarn/v6/`). They are not installed into any `node_modules`; they are used when a project's `package.json` asks for them and `yarn install` is run.

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

This image is intended to be used in CircleCI pipelines of Node.js projects using MongoDB (see the available tags at https://hub.docker.com/r/darthjee/circleci_node_mongo/tags).

1. As the CircleCI job executor image, in your `.circleci/config.yml`:

   ```yaml
   jobs:
     test:
       docker:
         - image: darthjee/circleci_node_mongo:<version>
         - image: mongo:<version>
       steps:
         - checkout
         - run: yarn install
         - run: yarn test
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_node_mongo:<version>

   COPY package.json /home/circleci/project/
   RUN yarn install
   ```

In both cases, `yarn install` resolves the pre-cached packages from the warm yarn cache instead of downloading them. `mongosh`, `mongodump`, `mongorestore` and the other tools are on the `PATH`, e.g. to seed or inspect the MongoDB service container in the job.

## License

See the LICENSE file for more information.
