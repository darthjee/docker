darthjee/production_ruby_3412
=============================

[![docker](https://img.shields.io/docker/v/darthjee/production_ruby_3412.svg?logo=docker&label=production_ruby_3412&sort=semver)](https://hub.docker.com/r/darthjee/production_ruby_3412)

## About the image

The `darthjee/production_ruby_3412` image is the production counterpart of [`darthjee/ruby_3412`](https://hub.docker.com/r/darthjee/ruby_3412), without development dependencies. It is not built on top of the dev image: like it, it is built on the official `ruby:3.4.12` image, but it skips the development and test gems to stay lightweight and suitable for running on production servers. Only the core gems required to run the application are pre-installed.

The image runs as the `app` user (uid 1000), with `/home/app/app` as its working directory, owned by `app`.

## Pre-installed gems

The following gems are pre-installed in the image:

### Core

- `bundler`
- `rake`
- `sinclair`
- `activesupport`

## How to use

This image is intended to be used as a base for production Docker images in Ruby projects. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_ruby_3412/tags):

```dockerfile
FROM darthjee/production_ruby_3412:<version>

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && bundle install
```

Projects can then install their own production gems on top of the shared base, taking advantage of Docker layer caching to speed up production builds.

## License

See the LICENSE file for more information.
