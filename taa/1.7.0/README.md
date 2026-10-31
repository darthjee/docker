darthjee/taa
============

## About the image

The `darthjee/taa` image is a Docker image built on top of [`darthjee/rails_yarn`](https://hub.docker.com/r/darthjee/rails_yarn). It pre-installs a set of **Rails gems** and pre-caches a set of **AngularJS packages**, providing a ready-to-use development environment for Rails applications with an AngularJS front end.

The image runs as the `app` user (uid 1000), with `/home/app/app` as the working directory, owned by `app`.

## What is added

On top of everything provided by `darthjee/rails_yarn` (Ruby, Node.js, Yarn, the Rails gems and the development and test gems), this image adds the following.

### Pre-installed gems

- `azeroth`
- `darthjee-active_ext`
- `jace`
- `magicka`
- `tarquinn`

### Pre-cached packages

The following packages are pre-cached in the global yarn cache (`/usr/local/share/.cache/yarn/v6/`). They are not installed into any `node_modules`; they are used when a project's `package.json` asks for them and `yarn install` is run.

- `angular`
- `angular-route`
- `cyberhawk`
- `johto`

> **Note:** The pre-cached `angular` and `angular-route` are version 1.8, a breaking upgrade from 1.4 (for example, the `$http` `.success()` / `.error()` methods were removed in 1.6); see the [AngularJS migration guide](https://docs.angularjs.org/guide/migration) before upgrading a project written against 1.4. The `js-cookie` pre-cached alongside them (shared with `darthjee/rails_yarn`) is version 3, a major upgrade with API changes (for example, `Cookies.getJSON` was removed); see the [js-cookie 3 migration notes](https://github.com/js-cookie/js-cookie/releases/tag/v3.0.0). The shared `jquery` is version 3.7, and `underscore` was bumped to a newer patch release.

## How to use

Reference this image in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/taa/tags):

```dockerfile
FROM darthjee/taa:<version>
```

Projects can then install their own specific gems and packages on top of the shared base, taking advantage of Docker layer caching to speed up builds and CI pipelines:

```dockerfile
FROM darthjee/taa:<version>

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=app:app package.json yarn.lock ./
RUN yarn install
```

## Variants

| Image | Purpose |
|---|---|
| `darthjee/taa` | Development environment with Rails, AngularJS gems and packages |
| `darthjee/circleci_taa` | CircleCI-optimized variant for running CI pipelines |
| `darthjee/production_taa` | Production-ready variant, stripped of development and test gems |

## License

See the LICENSE file for more information.
