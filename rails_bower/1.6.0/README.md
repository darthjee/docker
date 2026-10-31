darthjee/rails_bower
====================

## About the image

The `darthjee/rails_bower` image is a development image for Rails applications that manage their front-end assets with Bower. It is built on top of [`darthjee/ruby_node`](https://hub.docker.com/r/darthjee/ruby_node), which provides Ruby 3.3.1, Node.js and npm.

It comes with the gems most of these Rails applications need already installed, and with a pre-populated Bower cache, so a project's own `bundle install` and `bower install` only fetch what is missing.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## What is added

On top of everything provided by `darthjee/ruby_node`, this image adds:

- `bower` — installed globally with `npm`
- The gems listed in [Pre-installed gems](#pre-installed-gems), installed in `/usr/local/bundle`
- The Bower packages listed in [Pre-cached packages](#pre-cached-packages), cached in `/home/app/.cache/bower`

## Pre-installed gems

### Main

- `bundler`
- `darthjee-core_ext`
- `puma`
- `rack`
- `rake`
- `rails`
- `sass-rails`
- `uglifier`
- `nokogiri`
- `bower-rails`
- `turbolinks`
- `newrelic_rpm`
- `sinclair`
- `tzinfo-data`

### Development and test

- `pry`
- `pry-nav`
- `pry-rails`
- `simplecov`
- `yard`
- `yardstick`
- `zyra`

### Development

- `rubycritic`
- `reek`
- `rubocop`
- `rubocop-rspec`
- `zonebie`
- `web-console`

### Test

- `factory_bot`
- `rails-controller-testing`
- `rspec`
- `rspec-collection_matchers`
- `rspec-core`
- `rspec-expectations`
- `rspec-mocks`
- `rspec-rails`
- `rspec-support`
- `shoulda-matchers`
- `timecop`
- `webmock`

## Pre-cached packages

The Bower cache (`/home/app/.cache/bower`) comes pre-populated with:

- `underscore`
- `bootstrap`
- `jquery`
- `querystring`

They are not installed in any project; they are only used when a project's `bower.json` asks for them. Only the cached versions are reused; if your project pins different versions, Bower downloads those as usual.

## How to use

This image is intended to be used as a base for Rails applications that use Bower. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/rails_bower/tags):

```dockerfile
FROM darthjee/rails_bower:<version>

COPY --chown=app:app Gemfile Gemfile.lock bower.json /home/app/app/
RUN bundle install && bower install
```

Gems already installed in the image are reused when your `Gemfile.lock` asks for the same versions; only the project's other gems are installed.

The Bower cache is only reused when Bower runs as `app` with its default cache directory; mounting a volume over `/home/app` hides it.

## License

See the LICENSE file for more information.
