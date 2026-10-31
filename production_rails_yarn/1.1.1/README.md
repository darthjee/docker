darthjee/production_rails_yarn
==============================

## About the image

The `darthjee/production_rails_yarn` image is the production counterpart of [`darthjee/rails_yarn`](https://hub.docker.com/r/darthjee/rails_yarn), without development dependencies. Like the development image, it is built on top of [`darthjee/ruby_331`](https://hub.docker.com/r/darthjee/ruby_331) and adds **Node.js**, **npm** and **Yarn**, a pre-populated Yarn cache and the runtime **Rails application gems**.

This image does not install its Gemfile's development and test groups, and it sets `BUNDLE_WITHOUT` to `development:test`, so Bundler skips them too. Gems that come with `darthjee/ruby_331` (such as `rubocop`) are still present. The image also creates the `tmp/pids` directory that Puma needs, owned by `app`.

The image runs as the `app` user (uid 1000), with `/home/app/app` as its working directory.

## What is added

On top of everything provided by `darthjee/ruby_331`, this image installs:

- **Node.js** and **npm** (from NodeSource).
- **Yarn**, installed globally via npm.
- **ncat** and **telnet**, network utilities useful for debugging connectivity.

## Pre-cached packages

The Yarn cache (`/usr/local/share/.cache/yarn/v6`) is pre-populated with the following front-end packages. They are only used when a project's `package.json` asks for them:

- `yarn`
- `underscore`
- `bootstrap`
- `jquery`
- `js-cookie`

## Pre-installed gems

On top of the gems from `darthjee/ruby_331`, only the runtime gems are installed. The development and test groups are left out.

### Runtime

- `bundler`
- `darthjee-core_ext`
- `puma`
- `rack`
- `rake`
- `rails`
- `sass-rails`
- `uglifier`
- `nokogiri`
- `turbolinks`
- `sinclair`
- `tzinfo-data`
- `observer`

## How to use

Reference this image in your production `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_rails_yarn/tags):

```dockerfile
FROM darthjee/production_rails_yarn:<version>

COPY --chown=app:app . /home/app/app/
RUN bundle install
RUN yarn install --production
RUN bundle exec rake assets:precompile
```

Because `BUNDLE_WITHOUT` is set to `development:test`, `bundle install` only installs the main dependencies.

## License

See the LICENSE file for more information.
