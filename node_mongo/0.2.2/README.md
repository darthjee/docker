darthjee/node_mongo
===================

## About the image

The `darthjee/node_mongo` image is a Node.js 10 development image with the MongoDB command-line clients (`mongodb-clients`, installed from apt). It is built on top of [`darthjee/node`](https://hub.docker.com/r/darthjee/node) `0.0.7`, which is itself built on the official `node:10.7` image.

> **Note:** This is a legacy image built on an old, end-of-life Node.js base.

Its working directory is `/home/node/app`, and it runs as the `node` user.

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

- `mongodb-clients` (MongoDB command-line clients, e.g. the `mongo` shell)

## How to use

This image is intended to be used as a base for Node.js projects that need to talk to MongoDB. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/node_mongo/tags):

```dockerfile
FROM darthjee/node_mongo:<version>

COPY package.json /home/node/app/
RUN npm install
```

## License

See the LICENSE file for more information.
