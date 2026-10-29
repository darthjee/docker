darthjee/circleci_node_mongo
============================

## About the image

The `darthjee/circleci_node_mongo` image is a CircleCI image with Node.js 10 and the MongoDB command-line clients (`mongodb-clients`, installed from apt). It is built on top of [`darthjee/circleci_node`](https://hub.docker.com/r/darthjee/circleci_node) `0.0.7`, which is itself built on the `circleci/node:10.7` image. It is the CircleCI counterpart of [`darthjee/node_mongo`](https://hub.docker.com/r/darthjee/node_mongo), designed to run tests for Node.js + MongoDB projects on circleci.com.

> **Note:** This is a legacy image built on an old, end-of-life Node.js base (the deprecated `circleci/node` image).

Its working directory is `/home/circleci/project`, and it runs as the `circleci` user.

## Pre-installed packages

### Globally installed npm packages

The following packages are installed globally (`npm -g install`) by the base image:

- `express`
- `underscore`
- `express-generator`
- `jasmine`
- `jasmine-core`
- `eslint`
- `eslint-plugin-jasmine`
- `nock`
- `jsdoc`

### Tools

- `mongodb-clients` (MongoDB command-line clients, e.g. the `mongo` shell), useful for seeding or inspecting a MongoDB service container in the job

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
         - run: npm install
         - run: npm test
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_node_mongo:<version>

   COPY package.json /home/circleci/project/
   RUN npm install
   ```

## License

See the LICENSE file for more information.
