# Plan: Add README.md for darthjee/rails_bower

Issue: [165-add-readme-md-for-darthjee-rails-bower.md](../../issues/165-add-readme-md-for-darthjee-rails-bower.md)

## Overview
Write `rails_bower/1.4.0/README.md` (the folder the root `version` file points to: `rails_bower=1.4.0`), in place, following [`docs/agents/image-readme.md`](../../image-readme.md). It is the dev README of the family; `circleci_rails_bower` (#166) and `production_rails_bower` (#167) will reuse its structure.

## Context
Facts, all derived from `rails_bower/1.4.0/Dockerfile`, `home/Gemfile`, `home/bower.json` and the builder scripts (`bundle_builder.sh`, `bower_builder.sh` from `darthjee/scripts`):

- `FROM darthjee/ruby_node` (Ruby 3.3.1 via `darthjee/ruby_331`, plus Node.js and npm). Supported base: no legacy note.
- Adds `bower` globally (`npm install bower -g`) and creates `/home/app/.cache` owned by `app`.
- `bundle_builder.sh` runs a plain `bundle install` of the whole `Gemfile` (all groups) → gems installed in `/usr/local/bundle`.
- `bower_builder.sh` runs `bower install` of `bower.json` → only the Bower cache (`/home/app/.cache/bower`) is kept in the final image.
- User `app` (uid 1000), working directory `/home/app/app` owned by `app` (from `ruby_331`).

## Implementation Steps

### Step 1 — Write `rails_bower/1.4.0/README.md`
Create the file with exactly this content (adjust wording only if a fact turns out wrong against the Dockerfile):

````markdown
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
````

## Files to Change
- `rails_bower/1.4.0/README.md` — new file, the Docker Hub description of `darthjee/rails_bower`.

## Notes
- README-only change, made in place: no `bin/script.sh init`, no `version` bump, no `pre_build`/`build`/`test` (spec exception to CI checks).
- No `darthjee/` tags (neither `rails_bower`'s nor `ruby_node`'s), no gem/package versions, no architecture claims, absolute links only. Ruby 3.3.1 is allowed as part of the upstream base's identity.
- Do not copy `ruby_node/1.5.0/README.md`'s hardcoded tags and Node.js version: it predates the spec.
- Do not touch other version folders or other images; do not run `push_description` (handled by #171, and the family push also needs #166 and #167).
