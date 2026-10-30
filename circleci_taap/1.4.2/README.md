darthjee/circleci_taap
======================

## About the image

The `darthjee/circleci_taap` image is a CircleCI-optimized Docker image for Rails applications with an AngularJS front end that also need to plot charts. It is built on top of [`darthjee/circleci_taa`](https://hub.docker.com/r/darthjee/circleci_taa), which provides Ruby 3.3.1, Node.js, Yarn, the gems most of these Rails applications need and the AngularJS packages, and adds `gnuplot`.

It is the CircleCI counterpart of [`darthjee/taap`](https://hub.docker.com/r/darthjee/taap), designed to run tests for these applications on circleci.com, but it is not built on top of `darthjee/taap`.

Its working directory is `/home/circleci/project`, owned by the `circleci` user, which is also the image's default user.

## What is added

On top of everything provided by `darthjee/circleci_taa`, this image adds:

- `gnuplot` — installed with `apt-get`

## Pre-installed gems and packages

The gems (in `/home/circleci/.rubygems`, including the development and test groups) and the Node packages (in `/usr/lib/node_modules`) are the ones inherited from [`darthjee/circleci_taa`](https://hub.docker.com/r/darthjee/circleci_taa); see its description for the lists.

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
