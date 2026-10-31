darthjee/node_mongo
===================

## About the image

The `darthjee/node_mongo` image is a Node.js 22 development image with the MongoDB command-line tools. It is built on top of [`darthjee/node`](https://hub.docker.com/r/darthjee/node), which is itself built on the official `node:22` image. It is intended to be used as a base for Node.js projects that need to talk to MongoDB.

Its working directory is `/home/node/app`, owned by the `node` user, and it runs as the `node` user.

The image inherits the base image's warm yarn cache: a set of commonly used packages is pre-cached, so that when a project's `yarn install` asks for them they are resolved from the cache instead of being downloaded.

## What is added

On top of [`darthjee/node`](https://hub.docker.com/r/darthjee/node), the image adds:

- `mongosh` (the MongoDB Shell)
- MongoDB Database Tools (`mongodump`, `mongorestore`, `mongoimport`, `mongoexport`, `mongostat`, `mongotop`, ...)

The final user is switched from `root` to `node`.

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

## Variants

| Image | Use |
|-------|-----|
| [`darthjee/node_mongo`](https://hub.docker.com/r/darthjee/node_mongo) | Development |
| [`darthjee/circleci_node_mongo`](https://hub.docker.com/r/darthjee/circleci_node_mongo) | CircleCI |

## How to use

This image is intended to be used as a base for Node.js projects that need to talk to MongoDB. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/node_mongo/tags):

```dockerfile
FROM darthjee/node_mongo:<version>

COPY package.json /home/node/app/
RUN yarn install
```

Packages already present in the yarn cache are resolved locally, which speeds up `yarn install`. `mongosh`, `mongodump`, `mongorestore` and the other tools are on the `PATH`, e.g. to seed or inspect a MongoDB server from the container.

## License

See the LICENSE file for more information.
