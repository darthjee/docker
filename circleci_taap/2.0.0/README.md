darthjee/circleci_taap
======================

[![docker](https://img.shields.io/docker/v/darthjee/circleci_taap.svg?logo=docker&label=circleci_taap&sort=semver)](https://hub.docker.com/r/darthjee/circleci_taap)

## About the image

The `darthjee/circleci_taap` image is a CircleCI-optimized Docker image for Rails applications with an AngularJS front end that also need to plot charts. It is built on top of [`darthjee/circleci_taa`](https://hub.docker.com/r/darthjee/circleci_taa), which provides Ruby 3.4.12, Node.js 24, Bundler 4, Yarn, the gems most of these Rails applications need and the AngularJS packages, and adds the `danica` and `gnuplot` gems and the `gnuplot` command-line tool.

It is the CircleCI counterpart of [`darthjee/taap`](https://hub.docker.com/r/darthjee/taap), designed to run tests for these applications on circleci.com, but it is not built on top of `darthjee/taap`.

Its working directory is `/home/circleci/project`, owned by the `circleci` user, which is also the image's default user.

> **Note:** This image moved from Ruby 3.3.1 to Ruby 3.4.12, to Node.js 24 and to Bundler 4, inherited from `darthjee/circleci_taa`, and the gems it shares with `darthjee/circleci_taa` were upgraded along with the base (including Rails 7.2 patch releases and Rack 3.2). Check that your project runs on Ruby 3.4 and Node.js 24 before upgrading.

## What is added

On top of everything provided by `darthjee/circleci_taa`, this image adds:

- `danica` — gem for writing mathematical formulas and plotting them
- `gnuplot` — gem for driving gnuplot from Ruby
- the `gnuplot` command-line tool — installed with `apt-get` from the `gnuplot-nox` package, without X11/Qt support (it can render to files and terminals, not to GUI windows)

## Pre-installed gems and pre-cached packages

The `danica` and `gnuplot` gems are installed alongside the gems (in `/home/circleci/.rubygems`, including the development and test groups) inherited from [`darthjee/circleci_taa`](https://hub.docker.com/r/darthjee/circleci_taa). The Node packages are not installed: they are pre-cached in the Yarn cache (`/home/circleci/.cache/yarn/v6`, the default cache directory for the `circleci` user), also inherited, and only used when a project's `yarn install` asks for them. See the `darthjee/circleci_taa` description for the lists.

> **Note:** The JS packages pre-cached in [`darthjee/circleci_taa`](https://hub.docker.com/r/darthjee/circleci_taa) include breaking upgrades: `angular` / `angular-route` are version 1.8 (a breaking upgrade from 1.4), `js-cookie` is version 3 (a breaking upgrade from 2) and `jquery` is version 3.7. See the `darthjee/circleci_taa` description for the details and the migration links.

## How to use

This image is intended to be used in CircleCI pipelines of Rails applications with an AngularJS front end (see the available tags at https://hub.docker.com/r/darthjee/circleci_taap/tags).

1. As the CircleCI job executor image, in your `.circleci/config.yml`:

   ```yaml
   jobs:
     test:
       docker:
         - image: darthjee/circleci_taap:<version>
       steps:
         - checkout
         - run: bundle install
         - run: bundle exec rspec
   ```

2. As a base for projects building their own CI image on top of it, in your `Dockerfile`:

   ```dockerfile
   FROM darthjee/circleci_taap:<version>

   COPY --chown=circleci:circleci Gemfile Gemfile.lock /home/circleci/project/
   RUN bundle install
   ```

Gems already installed in the image are reused when your `Gemfile.lock` asks for the same versions; only the project's other gems are installed.

## License

See the LICENSE file for more information.
