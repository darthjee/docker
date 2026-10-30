darthjee/taap
=============

## About the image

The `darthjee/taap` image is a development image for Rails applications with an AngularJS front end that also need to plot charts. It is built on top of [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa), which provides Ruby 3.3.1, Node.js, Yarn, the gems most of these Rails applications need and the AngularJS packages, and adds `gnuplot`.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## What is added

On top of everything provided by `darthjee/taa`, this image adds:

- `gnuplot` — installed with `apt-get`

## Pre-installed gems and packages

The gems (in `/usr/local/bundle`, including the development and test groups) and the Node packages (in `/usr/lib/node_modules`) are the ones inherited from [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa); see its description for the lists.

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
