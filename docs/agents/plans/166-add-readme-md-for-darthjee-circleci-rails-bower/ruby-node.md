# Plan: Add README.md for darthjee/circleci_rails_bower

Issue: [166-add-readme-md-for-darthjee-circleci-rails-bower.md](../../issues/166-add-readme-md-for-darthjee-circleci-rails-bower.md)

## Overview
Write `circleci_rails_bower/1.4.0/README.md` (the folder the root `version` file points to: `circleci_rails_bower=1.4.0`), in place, following [`docs/agents/image-readme.md`](../../image-readme.md). It is the CircleCI counterpart of `darthjee/rails_bower`: reuse the merged `rails_bower/1.4.0/README.md` (#165) structure and wording, adapted to CircleCI the way `circleci_django/0.1.0/README.md` adapts `django`'s.

## Context
Facts, derived from `circleci_rails_bower/1.4.0/Dockerfile`, `home/Gemfile`, `home/bower.json` and the `darthjee/scripts:0.3.2` builder scripts (`bundle_builder.sh`, `bower_builder.sh`, from git history):

- `FROM darthjee/circleci_ruby_node` → `darthjee/circleci_ruby_331` → `cimg/ruby:3.3.1`, plus Node.js and npm. Not built on `darthjee/rails_bower`; `home/` is identical to `rails_bower/1.4.0/home/`.
- Adds `telnet` and `bower` globally (`npm install bower -g`); creates `/home/circleci/.cache` owned by `circleci`.
- `bundle_builder.sh` with `BUNDLE_FOLDER=/home/circleci/.rubygems` runs a plain `bundle install` (all groups) → gems installed in `/home/circleci/.rubygems`.
- `bower_builder.sh` → only the Bower cache (`/home/circleci/.cache/bower`) is kept in the final image.
- User `circleci`, working directory `/home/circleci/project` owned by `circleci` (from the `cimg/ruby` base).

## Implementation Steps

### Step 1 — Write `circleci_rails_bower/1.4.0/README.md`
Create the file with exactly this content (adjust wording only if a fact turns out wrong against the Dockerfile):

````markdown
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
````

## Files to Change
- `circleci_rails_bower/1.4.0/README.md` — new file.

## Notes
- README-only change, made in place: no `bin/script.sh init`, no `version` bump, no `pre_build`/`build`/`test` (spec exception to CI checks).
- No `darthjee/` tags, no gem/package versions, no architecture claims, absolute links only. Ruby 3.3.1 is allowed as part of the upstream base's identity.
- Do not copy `circleci_ruby_node/1.5.0/README.md` or `circleci_rails_gems/2.1.1/README.md`: they predate the spec and hardcode tags and versions.
- The counterpart link is one-way: do not edit `rails_bower/1.4.0/README.md`.
- Do not touch other version folders or images; do not run `push_description` (handled by #171; the family push also needs #167).
