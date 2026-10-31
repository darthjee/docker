darthjee/production_rails_yarn
==============================

## About the image

The `darthjee/production_rails_yarn` image is the production counterpart of [`darthjee/rails_yarn`](https://hub.docker.com/r/darthjee/rails_yarn), without development dependencies. It is a parallel image built on top of [`darthjee/production_ruby_331`](https://hub.docker.com/r/darthjee/production_ruby_331). It adds **Node.js**, **npm** and **Yarn**, pre-caches a set of front-end packages and pre-installs the production gems commonly used by Ruby on Rails applications. Development and test gems are excluded from the bundle, and the image sets `BUNDLE_WITHOUT` to `development:test`, so Bundler skips those groups too.

The image runs as the `app` user (uid 1000), with `/home/app/app` as the working directory, owned by `app`. It also creates the `tmp/pids` directory (owned by `app`) inside the working directory, as needed to run Puma.

## What is added

On top of everything provided by `darthjee/production_ruby_331`, this image installs:

- **Node.js** – JavaScript runtime, installed from NodeSource.
- **npm** – Node package manager.
- **Yarn** – JavaScript package manager, installed globally via npm.
- **ncat** and **telnet** – networking utilities, useful for checking connectivity to other services.

## Pre-cached packages

The following packages are pre-cached in the global yarn cache (`/usr/local/share/.cache/yarn/v6/`). They are not installed into any `node_modules`; they are used when a project's `package.json` asks for them and `yarn install` is run.

- `yarn`
- `underscore`
- `bootstrap`
- `jquery`
- `js-cookie`

## Pre-installed gems

Only production gems are pre-installed, on top of the ones provided by `darthjee/production_ruby_331`. Development and test groups are excluded.

### Core

- `bundler`
- `rake`
- `darthjee-core_ext`
- `sinclair`
- `observer`

### Rails

- `rails`
- `rack`
- `puma`
- `sass-rails`
- `uglifier`
- `nokogiri`
- `turbolinks`
- `tzinfo-data`

## How to use

Reference this image in your production `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_rails_yarn/tags), installing only the main dependencies. Because `BUNDLE_WITHOUT` is already set to `development:test`, a plain `bundle install` skips the development and test groups:

```dockerfile
FROM darthjee/production_rails_yarn:<version>

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=app:app package.json yarn.lock ./
RUN yarn install --production

COPY --chown=app:app . /home/app/app/
RUN bundle exec rake assets:precompile
```

## License

See the LICENSE file for more information.
