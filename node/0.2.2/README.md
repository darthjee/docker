darthjee/node
=============

## About the image

The `darthjee/node` image is a Node.js development image built on top of the official `node:22` image. It is intended to be used as a base for Node.js projects.

Its working directory is `/home/node/app`, which is owned by the `node` user (the image's default user is `root`; switch with `USER node` if needed).

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

This image is intended to be used as a base for Node.js projects. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/node/tags):

```dockerfile
FROM darthjee/node:<version>

COPY package.json /home/node/app/
RUN yarn install
```

Packages already present in the yarn cache are resolved locally, which speeds up `yarn install` and keeps project images small and fast to build.

## License

See the LICENSE file for more information.
