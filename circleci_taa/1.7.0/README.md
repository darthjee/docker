darthjee/circleci_taa
=====================

## About the image

The `darthjee/circleci_taa` image is the CircleCI counterpart of [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa). It is a parallel image, not built on top of `darthjee/taa`: it is built on top of [`darthjee/circleci_rails_yarn`](https://hub.docker.com/r/darthjee/circleci_rails_yarn). It pre-installs a set of **Rails gems** and pre-caches a set of **AngularJS packages**, providing a ready-to-use environment for running Rails and AngularJS application tests on circleci.com.

The image runs as the `circleci` user, with `/home/circleci/project` as the working directory, owned by `circleci`.

## What is added

On top of everything provided by `darthjee/circleci_rails_yarn` (Ruby, Node.js, Yarn, the Rails gems and the development and test gems), this image adds the following.

### Pre-installed gems

- `azeroth`
- `darthjee-active_ext`
- `jace`
- `magicka`
- `tarquinn`

### Pre-cached packages

The following packages are pre-cached in `/home/circleci/.cache/yarn/v6/`, yarn's default cache directory for the `circleci` user, alongside the packages inherited from `darthjee/circleci_rails_yarn`. They are not installed into any `node_modules`; they are used when a project's `package.json` asks for them and `yarn install` is run.

- `angular`
- `angular-route`
- `cyberhawk`
- `johto`

> **Note:** The pre-cached `angular` and `angular-route` are version 1.8, a breaking upgrade from 1.4 (for example, the `$http` `.success()` / `.error()` methods were removed in 1.6); see the [AngularJS migration guide](https://docs.angularjs.org/guide/migration) before upgrading a project written against 1.4. The `js-cookie` pre-cached alongside them (shared with `darthjee/circleci_rails_yarn`) is version 3, a major upgrade with API changes (for example, `Cookies.getJSON` was removed); see the [js-cookie 3 migration notes](https://github.com/js-cookie/js-cookie/releases/tag/v3.0.0). The shared `jquery` is version 3.7, and `underscore` was bumped to a newer patch release.

## How to use

Use it as the executor image in your `.circleci/config.yml` (see the available tags at https://hub.docker.com/r/darthjee/circleci_taa/tags):

```yaml
jobs:
  test:
    docker:
      - image: darthjee/circleci_taa:<version>
    steps:
      - checkout
      - run: bundle install
      - run: yarn install
      - run: bundle exec rspec
```

Or reference it in a `Dockerfile`:

```dockerfile
FROM darthjee/circleci_taa:<version>
```

## License

See the LICENSE file for more information.
