# Plan: Add README.md for darthjee/production_rails_bower

Issue: [167-add-readme-md-for-darthjee-production-rails-bower.md](../../issues/167-add-readme-md-for-darthjee-production-rails-bower.md)

## Overview
Write `production_rails_bower/1.4.0/README.md` (the folder the root `version` file points to: `production_rails_bower=1.4.0`), in place, following [`docs/agents/image-readme.md`](../../image-readme.md). It is the production counterpart of `darthjee/rails_bower`: reuse the merged `rails_bower/1.4.0/README.md` (#165) structure and wording, adapted to production the way `production_django/0.1.0/README.md` adapts `django`'s.

## Context
Facts, derived from `production_rails_bower/1.4.0/Dockerfile`, `home/Gemfile`, `home/bower.json`, `production_ruby_node/1.5.0/Dockerfile`, `production_ruby_331/1.1.1/Dockerfile` and the `darthjee/scripts:0.3.2` builder scripts (from git history):

- `FROM darthjee/production_ruby_node` → `darthjee/production_ruby_331` → official `ruby:3.3.1`, plus Node.js and npm. Not built on `darthjee/rails_bower`; `home/` is identical to `rails_bower/1.4.0/home/`.
- Adds `bower` globally (`npm install bower -g`); creates `/home/app/.cache` owned by `app`. No other tools.
- `bundle_builder.sh --without development test` → only the Main group of the Gemfile is installed, in `/usr/local/bundle`.
- `bower_builder.sh` → only the Bower cache (`/home/app/.cache/bower`) is kept in the final image.
- User `app` (uid 1000), working directory `/home/app/app` owned by `app` (from `production_ruby_331`).

## Implementation Steps

### Step 1 — Write `production_rails_bower/1.4.0/README.md`
Create the file with exactly this content (adjust wording only if a fact turns out wrong against the Dockerfile):

````markdown
darthjee/production_rails_bower
===============================

## About the image

The `darthjee/production_rails_bower` image is a production image for Rails applications that manage their front-end assets with Bower. It is built on top of [`darthjee/production_ruby_node`](https://hub.docker.com/r/darthjee/production_ruby_node), which provides Ruby 3.3.1, Node.js and npm.

It is the production counterpart of [`darthjee/rails_bower`](https://hub.docker.com/r/darthjee/rails_bower), installing only the main (non-development) gems. Both images cache the same Bower packages, but this one is not built on top of `darthjee/rails_bower`.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## What is added

On top of everything provided by `darthjee/production_ruby_node`, this image adds:

- `bower` — installed globally with `npm`
- The gems listed in [Pre-installed gems](#pre-installed-gems), installed in `/usr/local/bundle`
- The Bower packages listed in [Pre-cached packages](#pre-cached-packages), cached in `/home/app/.cache/bower`

## Pre-installed gems

Only the main gems are installed; development and test gems are not part of this image.

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

## Pre-cached packages

The Bower cache (`/home/app/.cache/bower`) comes pre-populated with:

- `underscore`
- `bootstrap`
- `jquery`
- `querystring`

They are not installed in any project; they are only used when a project's `bower.json` asks for them. Only the cached versions are reused; if your project pins different versions, Bower downloads those as usual.

## How to use

This image is intended to be used as a base for Rails applications that use Bower in production. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_rails_bower/tags):

```dockerfile
FROM darthjee/production_rails_bower:<version>

COPY --chown=app:app Gemfile Gemfile.lock bower.json /home/app/app/
RUN bundle config set --local without 'development test' && \
    bundle install && \
    bower install
```

Gems already installed in the image are reused when your `Gemfile.lock` asks for the same versions; only the project's other main gems are installed.

The Bower cache is only reused when Bower runs as `app` with its default cache directory; mounting a volume over `/home/app` hides it.

## License

See the LICENSE file for more information.
````

## Files to Change
- `production_rails_bower/1.4.0/README.md` — new file.

## Notes
- README-only change, made in place: no `bin/script.sh init`, no `version` bump, no `pre_build`/`build`/`test` (spec exception to CI checks).
- No `darthjee/` tags, no gem/package versions, no architecture claims, absolute links only. Ruby 3.3.1 is allowed as part of the upstream base's identity.
- Do not copy `production_ruby_331/1.1.1/README.md` or `circleci_rails_gems/2.1.1/README.md`: they predate the spec.
- The counterpart link is one-way: do not edit `rails_bower/1.4.0/README.md`.
- Do not touch other version folders or images; do not run `push_description` (handled by #171).
