## Description

Add `production_taap/1.4.2/README.md` describing the `darthjee/production_taap` image, so it can be pushed as the image's Docker Hub description (Epic #153). Today the image has no README, so its Docker Hub page has no description.

`darthjee/production_taap` is the production counterpart of [`darthjee/taap`](https://hub.docker.com/r/darthjee/taap): a production image for Rails applications with an AngularJS front end that also need to plot charts. It is built on top of `darthjee/production_taa` (not on `darthjee/taap`) and adds `gnuplot`.

The README follows [docs/agents/image-readme.md](../image-readme.md) and reuses the wording of `taap/1.4.2/README.md` (#168) and `production_rails_bower/1.4.0/README.md` (production counterpart paragraph).

## Facts from the image

Checked on the published `darthjee/production_taap:1.4.2`:

- User `app` (uid 1000), working directory `/home/app/app`.
- Ruby 3.3.1, Node.js, Yarn and the `gnuplot` binary (`/usr/bin/gnuplot`).
- Gems in `/usr/local/bundle`, main group only (`BUNDLE_WITHOUT=development:test`): the ones inherited from `darthjee/production_taa` (e.g. `azeroth`, `jace`, `magicka`, `tarquinn`, `rails`, `puma`, `newrelic_rpm`).
- The `danica` and `gnuplot` gems listed in `home/Gemfile` are **missing** — tracked in #200. The README must not list them.
- Node packages in `/usr/lib/node_modules` inherited from `darthjee/production_taa`: `angular`, `angular-route`, `bootstrap`, `cyberhawk`, `johto`, `jquery`, `js-cookie`, `underscore`, `yarn`.
- `home/bower.json` is copied but never used; the README does not mention Bower.

## Sections to write

- **Title**: `darthjee/production_taap`, underlined with `=`.
- **About the image**: production image for Rails + AngularJS apps that plot charts; built on [`darthjee/production_taa`](https://hub.docker.com/r/darthjee/production_taa) (Ruby 3.3.1, Node.js, Yarn, main gems, AngularJS packages); production counterpart of [`darthjee/taap`](https://hub.docker.com/r/darthjee/taap), installing only main gems, not built on top of it; `app` user and `/home/app/app`.
- **What is added**: `gnuplot`, installed with `apt-get`.
- **Pre-installed gems and packages**: main gems in `/usr/local/bundle` (no development/test groups) and Node packages in `/usr/lib/node_modules`, all inherited from `darthjee/production_taa`, with a link.
- **How to use**: tags link (https://hub.docker.com/r/darthjee/production_taap/tags) and a `Dockerfile` example with `FROM darthjee/production_taap:<version>`, copying `Gemfile`/`Gemfile.lock` as `app` and running `bundle install` with `development test` excluded; the gem-reuse sentence.
- **License**: "See the LICENSE file for more information."

## Process

- Add the file **in place** in `production_taap/1.4.2/`: no `bin/script.sh init`, no version bump, no build or test. `README.md` is never copied into the image.
- No hardcoded `darthjee/` tags, no tool/gem/package versions (Ruby 3.3.1 excepted), no architecture claims, absolute links only.
- The pre-spec `production_taa/1.5.0/README.md` is not a template.
- Write in English.

## Dependencies

- #168 (`darthjee/taap` README): merged; its wording is the model.
- #200: once the missing gems are fixed, the README should list `danica` and `gnuplot`.
- #171: pushing descriptions to Docker Hub is done by the CI release job, not here.

## Responsible agent

`ruby-node`

## Testing

No automated tests. Review the README against `docs/agents/image-readme.md`; after #171 and the next release, the `darthjee/production_taap` Docker Hub page shows it.

Parent epic: #153
