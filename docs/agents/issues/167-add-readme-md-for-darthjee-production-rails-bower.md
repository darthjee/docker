# Issue: Add README.md for darthjee/production_rails_bower

## Description

Add `production_rails_bower/1.4.0/README.md` describing the `darthjee/production_rails_bower` image, so it can be pushed as the Docker Hub description of `darthjee/production_rails_bower` (see `bin/push_description.sh`). Today the image has no README, so its Docker Hub page has no description, and `bin/script.sh push_description rails_bower` fails for the whole family.

Write it following [`docs/agents/image-readme.md`](../image-readme.md). It is the production counterpart of `darthjee/rails_bower`: reuse the structure and wording of the merged `rails_bower/1.4.0/README.md` (#165), adapting it to production the same way `production_django/0.1.0/README.md` (#164) adapts `django`'s.

## Facts from the image (`production_rails_bower/1.4.0/Dockerfile`)

- Built `FROM darthjee/production_ruby_node` (link https://hub.docker.com/r/darthjee/production_ruby_node, no tag), which is built on `darthjee/production_ruby_331` (the official `ruby:3.3.1` image) and adds Node.js and npm. It is **not** built on top of `darthjee/rails_bower`; both images ship the same `Gemfile` and `bower.json` (`home/` is identical).
- Default user `app` (uid 1000); working directory `/home/app/app`, owned by `app`.
- Adds **Bower**, installed globally with `npm`. No other tools.
- `bundle_builder.sh` (scripts 0.3.2) runs `bundle install --without development test`, so only the **Main** group of `home/Gemfile` is installed, in `/usr/local/bundle`. The development and test gems are not in the image.
- `bower_builder.sh` keeps only the **Bower cache** in `/home/app/.cache/bower`: `underscore`, `bootstrap`, `jquery`, `querystring`.

## Sections to write

- Title `darthjee/production_rails_bower`, underlined with `=` to its length.
- **About the image:** a production image for Rails applications that manage front-end assets with Bower, built on top of [`darthjee/production_ruby_node`](https://hub.docker.com/r/darthjee/production_ruby_node) (Ruby 3.3.1, Node.js and npm). It is the production counterpart of [`darthjee/rails_bower`](https://hub.docker.com/r/darthjee/rails_bower), installing only the main (non-development) gems; both cache the same Bower packages, but this one is not built on top of `rails_bower`. Then the `app` user/working-directory paragraph.
- **What is added:** Bower (global), the pre-installed main gems (in `/usr/local/bundle`) and the pre-cached Bower packages (in `/home/app/.cache/bower`), on top of `production_ruby_node`.
- **Pre-installed gems:** only the Main list from `rails_bower`, names only, no `###` groups.
- **Pre-cached packages:** same as `rails_bower`.
- **How to use:** link to https://hub.docker.com/r/darthjee/production_rails_bower/tags, then a base `Dockerfile`:

  ```dockerfile
  FROM darthjee/production_rails_bower:<version>

  COPY --chown=app:app Gemfile Gemfile.lock bower.json /home/app/app/
  RUN bundle config set --local without 'development test' && \
      bundle install && \
      bower install
  ```

  Then the gem-reuse sentence (only main gems are in the image) and the caveat that the Bower cache is only reused when Bower runs as `app` with its default cache directory (mounting a volume over `/home/app` hides it).
- No `Variants` table.
- **License:** "See the LICENSE file for more information."

## Process

- Add the file **in place** in `production_rails_bower/1.4.0/` (the folder `version` points to): no `bin/script.sh init`, no version bump, no `pre_build`/`build`/`test`. `README.md` sits beside `home/` and is never copied into the image.
- No hardcoded `darthjee/` tags, no gem/package versions (Ruby 3.3.1 is allowed as part of the base's identity), no architecture claims, absolute links only.
- Do not use `production_ruby_331`'s or `circleci_rails_gems`'s READMEs as templates: they predate the spec.
- The link to the dev image is one-way; do not edit `rails_bower/1.4.0/README.md`.
- Write in English.

## Dependencies

- #165 (`darthjee/rails_bower` README) — merged; reuse its wording.
- #166 (`darthjee/circleci_rails_bower` README) — merged. With this issue the `rails_bower` family has all three READMEs.
- Pushing to Docker Hub is handled separately (#171); this issue only adds the file.

## Responsible agent

`ruby-node`

## Testing

No automated tests. Check the README against the spec's content rules. Verified manually once descriptions are pushed: the `darthjee/production_rails_bower` Docker Hub page shows this README.

Parent epic: #153
