darthjee/circleci_rails_bower
=============================

## About the image

The `darthjee/circleci_rails_bower` image is a CircleCI-optimized Docker image for Rails applications that manage their front-end assets with Bower. It is built on top of [`darthjee/circleci_ruby_node`](https://hub.docker.com/r/darthjee/circleci_ruby_node), which provides Ruby 3.3.1, Node.js and npm.

It is the CircleCI counterpart of [`darthjee/rails_bower`](https://hub.docker.com/r/darthjee/rails_bower), designed to run tests for these applications on circleci.com. Both images install the same gems and cache the same Bower packages, but this one is not built on top of `darthjee/rails_bower`.

It comes with the gems most of these Rails applications need already installed, and with a pre-populated Bower cache, so a project's own `bundle install` and `bower install` only fetch what is missing.

Its working directory is `/home/circleci/project`, owned by the `circleci` user, which is also the image's default user.

## What is added

On top of everything provided by `darthjee/circleci_ruby_node`, this image adds:

- `bower` — installed globally with `npm`
- `telnet`
- The gems listed in [Pre-installed gems](#pre-installed-gems), installed in `/home/circleci/.rubygems`
- The Bower packages listed in [Pre-cached packages](#pre-cached-packages), cached in `/home/circleci/.cache/bower`

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

The Bower cache (`/home/circleci/.cache/bower`) comes pre-populated with:

- `underscore`
- `bootstrap`
- `jquery`
- `querystring`

They are not installed in any project; they are only used when a project's `bower.json` asks for them. Only the cached versions are reused; if your project pins different versions, Bower downloads those as usual.

## Upgrading from 1.x

Version 2.0.0 aligns the gem pins with the gems already installed by the Ruby base image, so each gem is installed only once. This is a breaking change for projects built on this image, which may need code or configuration changes to upgrade:

- `rails` moves from 7.0 to 7.2
- `sinclair` moves from 2 to 3
- `rubocop` moves from 1.59 to 1.85, and `rubocop-rspec` from 2 to 3, so new cops and renamed or removed cops may need `.rubocop.yml` updates
- `rspec-rails` moves from 6 to 7, which supports Rails 7.2
- `rspec` and its component gems move from 3.12 to 3.13
- `rake`, `reek`, `rubycritic`, `yard` and `web-console` also move to newer versions

Projects that still need Rails 7.0 can stay on the 1.x tags.

## How to use

This image is intended to be used in CircleCI pipelines of Rails applications that use Bower (see the available tags at https://hub.docker.com/r/darthjee/circleci_rails_bower/tags).

1. As the CircleCI job executor image, in your `.circleci/config.yml`:

   ```yaml
   jobs:
     test:
       docker:
         - image: darthjee/circleci_rails_bower:<version>
       steps:
         - checkout
         - run: bundle install
         - run: bower install
         - run: bundle exec rspec
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_rails_bower:<version>

   COPY --chown=circleci:circleci Gemfile Gemfile.lock bower.json /home/circleci/project/
   RUN bundle install && bower install
   ```

Gems already installed in the image are reused when your `Gemfile.lock` asks for the same versions; only the project's other gems are installed.

The Bower cache is only reused when Bower runs as `circleci` with its default cache directory; mounting a volume over `/home/circleci` hides it.

## License

See the LICENSE file for more information.
