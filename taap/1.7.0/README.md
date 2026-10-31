darthjee/taap
=============

## About the image

The `darthjee/taap` image is a development image for Rails applications with an AngularJS front end that also need to plot charts. It is built on top of [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa), which provides Ruby 3.3.1, Node.js, Yarn, the gems most of these Rails applications need and the AngularJS packages, and adds the `danica` and `gnuplot` gems and the `gnuplot` binary.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## What is added

On top of everything provided by `darthjee/taa`, this image adds:

- `danica` — gem for writing mathematical formulas and plotting them
- `gnuplot` — gem for driving gnuplot from Ruby
- the `gnuplot` binary — installed with `apt-get`

## Pre-installed gems and pre-cached packages

The `danica` and `gnuplot` gems are installed alongside the gems (in `/usr/local/bundle`, including the development and test groups) inherited from [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa). The Node packages are not installed: they are pre-cached in the Yarn cache (`/usr/local/share/.cache/yarn/v6`), also inherited, and only used when a project's `yarn install` asks for them. See the `darthjee/taa` description for the lists.

> **Note:** The JS packages pre-cached in [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa) were upgraded there: `angular` / `angular-route` are version 1.8 (a breaking upgrade from 1.4), `js-cookie` is version 3 (a breaking upgrade from 2) and `jquery` is version 3.7. See the `darthjee/taa` description for the details and the migration links.

## How to use

This image is intended to be used as a base for Rails applications with an AngularJS front end. To build on top of it, reference it in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/taap/tags):

```dockerfile
FROM darthjee/taap:<version>

COPY --chown=app:app Gemfile Gemfile.lock /home/app/app/
RUN bundle install
```

Gems already installed in the image are reused when your `Gemfile.lock` asks for the same versions; only the project's other gems are installed.

## License

See the LICENSE file for more information.
