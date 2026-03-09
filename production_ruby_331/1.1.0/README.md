darthjee/production_ruby_331
=============================

## About the image

The `darthjee/production_ruby_331` image is a production-ready Docker image built on top of the official `ruby:3.3.1` image. It is the production counterpart of `darthjee/ruby_331`, stripped of development and test dependencies to be lightweight and suitable for running in production servers. Only the core gems required to run the application are pre-installed.

## Pre-installed gems

The following gems are pre-installed in the image:

### Core

- `bundler`
- `rake`
- `sinclair`
- `activesupport`

## How to use

This image is intended to be used as a base for production Docker images in Ruby projects. To build on top of it, reference it in your `Dockerfile`:

```dockerfile
FROM darthjee/production_ruby_331:1.1.0
```

Projects can then install their own production-specific gems on top of the shared base, taking advantage of Docker layer caching to speed up production builds.

## License

See the LICENSE file for more information.
