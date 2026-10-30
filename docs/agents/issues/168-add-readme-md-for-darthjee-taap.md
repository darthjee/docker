# Issue: Add README.md for darthjee/taap

## Description

Add `taap/1.4.2/README.md` describing the `darthjee/taap` image, so it can be pushed as the Docker Hub description of `darthjee/taap` (see `bin/push_description.sh`). Today the image has no README, so its Docker Hub page has no description, and `bin/script.sh push_description taap` fails for the whole family.

Write it following [`docs/agents/image-readme.md`](../image-readme.md), reusing the structure and wording of the merged `rails_bower/1.4.0/README.md` (#165) and `django/0.1.0/README.md` where they fit. The README describes **what the published image really ships**, not what `home/Gemfile` intends (see #197).

## Facts from the image (`taap/1.4.2/Dockerfile` and the published `darthjee/taap:1.4.2`)

- Built `FROM darthjee/taa` (link https://hub.docker.com/r/darthjee/taa, no tag), the Rails + AngularJS development image, which is built on `darthjee/rails_yarn` and provides Ruby 3.3.1, Node.js and Yarn.
- Default user `app` (uid 1000); working directory `/home/app/app`, owned by `app`.
- Adds the **`gnuplot`** command-line tool, installed with `apt-get` in the final stage. This is the only addition that actually ships.
- Gems: everything in `/usr/local/bundle` comes from `darthjee/taa`, including the development and test groups. The `danica` and `gnuplot` gems listed in `home/Gemfile` are **not** in the published image (#197), so the README must not list them.
- Node packages: the ones in `/usr/lib/node_modules` (AngularJS and friends) are inherited from `darthjee/taa`. `home/bower.json` is copied but never used, because nothing runs Bower; ignore it.

## Sections to write

- Title `darthjee/taap`, underlined with `=` to its length.
- **About the image:** a development image for Rails applications with an AngularJS front end that also need plotting. It is built on top of [`darthjee/taa`](https://hub.docker.com/r/darthjee/taa) and adds `gnuplot`. Then the `app` user/working-directory paragraph.
- **What is added:** the `gnuplot` tool, on top of everything `darthjee/taa` provides.
- **Pre-installed gems / packages:** no lists. One sentence saying the gems (in `/usr/local/bundle`) and Node packages (in `/usr/lib/node_modules`) are the ones inherited from `darthjee/taa`, with a link to it.
- **How to use:** link to https://hub.docker.com/r/darthjee/taap/tags, then a base `Dockerfile`:

  ```dockerfile
  FROM darthjee/taap:<version>

  COPY --chown=app:app Gemfile Gemfile.lock /home/app/app/
  RUN bundle install
  ```

  Then the gem-reuse sentence (gems already in the image are reused; only the project's other gems are installed). Make no claim about Yarn reusing the global Node packages.
- No `Variants` table.
- **License:** "See the LICENSE file for more information."

## Process

- Add the file **in place** in `taap/1.4.2/` (the folder `version` points to): no `bin/script.sh init`, no version bump, no `pre_build`/`build`/`test`. `README.md` sits beside `home/` and is never copied into the image.
- No hardcoded `darthjee/` tags, no gem/package/tool versions (Ruby 3.3.1 is allowed as part of the base's identity), no architecture claims, absolute links only.
- Do not use `taa/1.5.0/README.md` or `circleci_rails_gems`'s README as templates: they predate the spec. Do not edit `taa`'s README.
- Write in English.

## Dependencies

- #197 (missing `danica`/`gnuplot` gems): independent. When it is fixed, the README should be updated to list the two gems.
- #169 (`circleci_taap`) and #170 (`production_taap`) are the counterparts; they reuse this README's wording.
- Pushing to Docker Hub is handled separately (#171); this issue only adds the file.

## Responsible agent

`ruby-node`

## Testing

No automated tests. Check the README against the spec's content rules and against the published image (no `danica`/`gnuplot` gems listed). Verified manually once descriptions are pushed: the `darthjee/taap` Docker Hub page shows this README.

Parent epic: #153
