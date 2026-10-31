darthjee/production_taa
=======================

## About the image

The `darthjee/production_taa` image is the production counterpart of [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa), without development dependencies. It is a parallel image built on top of [`darthjee/production_rails_yarn`](https://hub.docker.com/r/darthjee/production_rails_yarn). It pre-installs a set of production **Rails gems** and pre-caches a set of **AngularJS packages**. Development and test gems are excluded from the bundle.

The image runs as the `app` user (uid 1000), with `/home/app/app` as the working directory, owned by `app`. The `tmp/pids` directory (owned by `app`) inside the working directory, needed to run Puma, is provided by the base image.

## What is added

On top of everything provided by `darthjee/production_rails_yarn` (Ruby, Node.js, Yarn and the production Rails gems), this image adds the following.

### Pre-installed gems

Only production gems are pre-installed. Development and test groups are excluded.

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

> **Note:** The pre-cached `angular` and `angular-route` are version 1.8, a breaking upgrade from 1.4 (for example, the `$http` `.success()` / `.error()` methods were removed in 1.6); see the [AngularJS migration guide](https://docs.angularjs.org/guide/migration) before upgrading a project written against 1.4. The `js-cookie` pre-cached alongside them (shared with `darthjee/production_rails_yarn`) is version 3, a major upgrade with API changes (for example, `Cookies.getJSON` was removed); see the [js-cookie 3 migration notes](https://github.com/js-cookie/js-cookie/releases/tag/v3.0.0). The shared `jquery` is version 3.7, and `underscore` was bumped to a newer patch release.

## How to use

Reference this image in your production `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_taa/tags), installing only the main dependencies:

```dockerfile
FROM darthjee/production_taa:<version>

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && \
    bundle install

COPY --chown=app:app package.json yarn.lock ./
RUN yarn install --production

COPY --chown=app:app . /home/app/app/
RUN bundle exec rake assets:precompile
```

## License

See the LICENSE file for more information.
