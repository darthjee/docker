darthjee/production_taap
========================

## About the image

The `darthjee/production_taap` image is a production image for Rails applications with an AngularJS front end that also need to plot charts. It is built on top of [`darthjee/production_taa`](https://hub.docker.com/r/darthjee/production_taa), which provides Ruby 3.3.1, Node.js, Yarn, the main gems most of these Rails applications need and the AngularJS packages, and adds the `danica` and `gnuplot` gems and the `gnuplot` binary.

It is the production counterpart of [`darthjee/taap`](https://hub.docker.com/r/darthjee/taap), installing only the main (non-development) gems. It is not built on top of `darthjee/taap`.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## What is added

On top of everything provided by `darthjee/production_taa`, this image adds:

- `danica` — gem for writing mathematical formulas and plotting them
- `gnuplot` — gem for driving gnuplot from Ruby
- the `gnuplot` binary — installed with `apt-get`

## Pre-installed gems and pre-cached packages

The `danica` and `gnuplot` gems are installed alongside the gems (in `/usr/local/bundle`, main group only; development and test gems are not part of this image) inherited from [`darthjee/production_taa`](https://hub.docker.com/r/darthjee/production_taa). The Node packages are not installed: they are pre-cached in the Yarn cache (`/usr/local/share/.cache/yarn/v6`), also inherited, and only used when a project's `yarn install` asks for them. See the `darthjee/production_taa` description for the lists.

> **Note:** The JS packages pre-cached in [`darthjee/production_taa`](https://hub.docker.com/r/darthjee/production_taa) **1.7.0** were upgraded in that release: `angular` / `angular-route` are version 1.8 (a breaking upgrade from 1.4), `js-cookie` is version 3 (a breaking upgrade from 2) and `jquery` is version 3.7. See the `darthjee/production_taa` description for the details and the migration links.

## How to use

This image is intended to be used as a base for Rails applications with an AngularJS front end in production. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/production_taap/tags):

```dockerfile
FROM darthjee/production_taap:<version>

COPY --chown=app:app Gemfile Gemfile.lock /home/app/app/
RUN bundle config set --local without 'development test' && \
    bundle install
```

Gems already installed in the image are reused when your `Gemfile.lock` asks for the same versions; only the project's other main gems are installed.

## License

See the LICENSE file for more information.
