# Issue: Add README.md for darthjee/circleci_rails_bower

## Description

Add `circleci_rails_bower/1.4.0/README.md` describing the `darthjee/circleci_rails_bower` image, so it can be pushed as the Docker Hub description of `darthjee/circleci_rails_bower` (see `bin/push_description.sh`). Today the image has no README, so its Docker Hub page has no description, and `bin/script.sh push_description rails_bower` fails for the whole family.

Write it following [`docs/agents/image-readme.md`](../image-readme.md). It is the CircleCI counterpart of `darthjee/rails_bower`: reuse the structure and wording of the merged `rails_bower/1.4.0/README.md` (#165), adapting paths, user and usage to CircleCI, the same way `circleci_django/0.1.0/README.md` reuses `django`'s.

## Facts from the image (`circleci_rails_bower/1.4.0/Dockerfile`)

- Built `FROM darthjee/circleci_ruby_node` (link https://hub.docker.com/r/darthjee/circleci_ruby_node, no tag), which is built on `darthjee/circleci_ruby_331` (`cimg/ruby:3.3.1`) and adds Node.js and npm. It is **not** built on top of `darthjee/rails_bower`; both images ship the same `Gemfile` and `bower.json` (`home/` is identical).
- Default user `circleci`; working directory `/home/circleci/project`, owned by `circleci` (from the `cimg/ruby` base).
- Adds **Bower**, installed globally with `npm`, and `telnet`.
- `bundle_builder.sh` (scripts 0.3.2, `BUNDLE_FOLDER=/home/circleci/.rubygems`) runs a plain `bundle install` of `home/Gemfile` (all groups), so the gems are **installed** in `/home/circleci/.rubygems` — same list and groups as `rails_bower`.
- `bower_builder.sh` keeps only the **Bower cache** in `/home/circleci/.cache/bower`: `underscore`, `bootstrap`, `jquery`, `querystring`.

## Sections to write

- Title `darthjee/circleci_rails_bower`, underlined with `=` to its length.
- **About the image:** a CircleCI image for Rails applications that manage front-end assets with Bower, built on top of [`darthjee/circleci_ruby_node`](https://hub.docker.com/r/darthjee/circleci_ruby_node) (Ruby 3.3.1, Node.js and npm). It is the CircleCI counterpart of [`darthjee/rails_bower`](https://hub.docker.com/r/darthjee/rails_bower), designed to run tests on circleci.com; both install the same gems and cache the same Bower packages, but this one is not built on top of `rails_bower`. Then the `circleci` user/working-directory paragraph.
- **What is added:** Bower (global), `telnet`, the pre-installed gems (in `/home/circleci/.rubygems`) and the pre-cached Bower packages (in `/home/circleci/.cache/bower`), on top of `circleci_ruby_node`.
- **Pre-installed gems:** same grouped list as `rails_bower` (Main, Development and test, Development, Test), names only.
- **Pre-cached packages:** same as `rails_bower`, with the `/home/circleci/.cache/bower` path.
- **How to use:** link to https://hub.docker.com/r/darthjee/circleci_rails_bower/tags; two usages like `circleci_django`:
  1. as the job executor in `.circleci/config.yml` (`image: darthjee/circleci_rails_bower:<version>`, steps `checkout`, `bundle install`, `bower install`, `bundle exec rspec`);
  2. as a base `Dockerfile` (`FROM darthjee/circleci_rails_bower:<version>`, copy `Gemfile`, `Gemfile.lock`, `bower.json` to `/home/circleci/project/` with `--chown=circleci:circleci`, `RUN bundle install && bower install`).
  Then the gem-reuse sentence and the caveat that the Bower cache is only reused when Bower runs as `circleci` with its default cache directory (mounting a volume over `/home/circleci` hides it).
- No `Variants` table.
- **License:** "See the LICENSE file for more information."

## Process

- Add the file **in place** in `circleci_rails_bower/1.4.0/` (the folder `version` points to): no `bin/script.sh init`, no version bump, no `pre_build`/`build`/`test`. `README.md` sits beside `home/` and is never copied into the image.
- No hardcoded `darthjee/` tags, no gem/package versions, no architecture claims, absolute links only.
- Do not use `circleci_ruby_node/1.5.0/README.md` or `circleci_rails_gems/2.1.1/README.md` as templates: they predate the spec and hardcode tags and versions.
- The link to the dev image is one-way; do not edit `rails_bower/1.4.0/README.md`.
- Write in English.

## Dependencies

- #165 (`darthjee/rails_bower` README) — merged; reuse its wording.
- Pushing to Docker Hub is handled separately (#171); this issue only adds the file. The family push also needs #167.

## Responsible agent

`ruby-node`

## Testing

No automated tests. Check the README against the spec's content rules. Verified manually once descriptions are pushed: the `darthjee/circleci_rails_bower` Docker Hub page shows this README.

Parent epic: #153
