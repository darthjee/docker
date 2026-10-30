# Plan (ruby-node): Add README.md for darthjee/taap

## Step 1 — Write `taap/1.4.2/README.md`

Create the file **in place** in `taap/1.4.2/` (the folder the root `version` file points to), beside `Dockerfile` and `home/`. Do not run `bin/script.sh init`, do not bump any version, do not build or test. Use exactly this content:

````markdown
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
````

## Notes

- The title underline is 13 `=` characters, the length of `darthjee/taap`.
- Do not list `danica` or `gnuplot` gems: they are missing from the published image (#197). When #197 is fixed, that issue updates this README.
- Do not mention `home/bower.json`: nothing runs Bower in this image.
- No hardcoded `darthjee/` tags, no tool/gem/package versions (Ruby 3.3.1 is part of the base's identity), no architecture claims, absolute links only.
- Do not copy `taa/1.5.0/README.md` or `circleci_rails_gems`'s README (they predate the spec), and do not edit `taa`'s README.
- Do not push the description to Docker Hub (#171).
