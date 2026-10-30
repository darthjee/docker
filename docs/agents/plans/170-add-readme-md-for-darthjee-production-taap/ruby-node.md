# ruby-node: Write production_taap/1.4.2/README.md

## Files

- Create `production_taap/1.4.2/README.md` (beside `Dockerfile`, `home/` and `test/`). Touch nothing else.

## Content

Write exactly this (wording may be polished, but keep the facts and the structure):

````markdown
darthjee/production_taap
========================

## About the image

The `darthjee/production_taap` image is a production image for Rails applications with an AngularJS front end that also need to plot charts. It is built on top of [`darthjee/production_taa`](https://hub.docker.com/r/darthjee/production_taa), which provides Ruby 3.3.1, Node.js, Yarn, the main gems most of these Rails applications need and the AngularJS packages, and adds `gnuplot`.

It is the production counterpart of [`darthjee/taap`](https://hub.docker.com/r/darthjee/taap), installing only the main (non-development) gems. It is not built on top of `darthjee/taap`.

Its working directory is `/home/app/app`, which is owned by the `app` user (uid 1000), also the image's default user.

## What is added

On top of everything provided by `darthjee/production_taa`, this image adds:

- `gnuplot` — installed with `apt-get`

## Pre-installed gems and packages

The gems (in `/usr/local/bundle`, main group only; development and test gems are not part of this image) and the Node packages (in `/usr/lib/node_modules`) are the ones inherited from [`darthjee/production_taa`](https://hub.docker.com/r/darthjee/production_taa); see its description for the lists.

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
````

## Notes

- The title underline is 24 `=` characters, matching `darthjee/production_taap`.
- Do not list the `danica` or `gnuplot` gems: the published image does not ship them (#200).
- Do not mention `home/bower.json`; nothing uses it.
- Do not use `production_taa/1.5.0/README.md` as a template (pre-spec: hardcoded tags and versions).
- No hardcoded `darthjee/` tags, no gem/package/tool versions (except Ruby 3.3.1), no architecture claims.
- Do not run `bin/script.sh init`, `pre_build`, `build` or `test`, and do not push the description (#171).
