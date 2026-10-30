## Description

Add `rails_bower/1.4.0/README.md` describing the `darthjee/rails_bower` image, so it can be pushed as the Docker Hub description of `darthjee/rails_bower` (see `bin/push_description.sh`). Today the image has no README, so its Docker Hub page has no description, and `bin/script.sh push_description rails_bower` fails for the whole family.

Write it following [`docs/agents/image-readme.md`](../image-readme.md). This is the dev README of the family: `circleci_rails_bower` (#166) and `production_rails_bower` (#167) will reuse its structure and wording.

## Facts from the image (`rails_bower/1.4.0/Dockerfile`)

- Built `FROM darthjee/ruby_node` (link https://hub.docker.com/r/darthjee/ruby_node, no tag), which is itself built on `darthjee/ruby_331` (`ruby:3.3.1`) and adds Node.js and npm. The base is supported, so no legacy note.
- Default user `app` (uid 1000); working directory `/home/app/app`, owned by `app` (inherited from `ruby_331`).
- Adds **Bower**, installed globally with `npm`.
- `bundle_builder.sh` runs a plain `bundle install` of `home/Gemfile` (all groups), so the gems are **installed** in `/usr/local/bundle`:
  - main: `bundler`, `darthjee-core_ext`, `puma`, `rack`, `rake`, `rails`, `sass-rails`, `uglifier`, `nokogiri`, `bower-rails`, `turbolinks`, `newrelic_rpm`, `sinclair`, `tzinfo-data`;
  - development and test: `pry`, `pry-nav`, `pry-rails`, `simplecov`, `yard`, `yardstick`, `zyra`;
  - development: `rubycritic`, `reek`, `rubocop`, `rubocop-rspec`, `zonebie`, `web-console`;
  - test: `factory_bot`, `rails-controller-testing`, `rspec`, `rspec-collection_matchers`, `rspec-core`, `rspec-expectations`, `rspec-mocks`, `rspec-rails`, `rspec-support`, `shoulda-matchers`, `timecop`, `webmock`.
- `bower_builder.sh` runs `bower install` of `home/bower.json` and keeps only the **Bower cache** in `/home/app/.cache/bower`: `underscore`, `bootstrap`, `jquery`, `querystring`. These are cached, not installed in a project.

## Sections to write

- Title `darthjee/rails_bower`, underlined with `=` to its length.
- **About the image:** a development image for Rails applications that manage front-end assets with Bower, built on top of [`darthjee/ruby_node`](https://hub.docker.com/r/darthjee/ruby_node) (Ruby, Node.js and npm). Then the user/working-directory paragraph.
- **What is added:** Bower (global), the pre-installed gems and the pre-cached Bower packages, on top of `ruby_node`.
- **Pre-installed gems:** the list above, grouped with `###` subheadings (Main, Development and test, Development, Test), names only.
- **Pre-cached packages:** the Bower packages, saying the cache lives in `/home/app/.cache/bower` and is only used when a project's `bower.json` asks for them (only the cached versions are reused).
- **How to use:** link to https://hub.docker.com/r/darthjee/rails_bower/tags; a `Dockerfile` example `FROM darthjee/rails_bower:<version>` that copies `Gemfile`, `Gemfile.lock` and `bower.json` and runs `bundle install` and `bower install`; a sentence that gems already installed are reused and only the project's extra gems are installed.
- No `Variants` table (optional; left out).
- **License:** "See the LICENSE file for more information."

## Process

- Add the file **in place** in `rails_bower/1.4.0/` (the folder `version` points to): no `bin/script.sh init`, no version bump, no `pre_build`/`build`/`test`. `README.md` sits beside `home/` and is never copied into the image.
- No hardcoded `darthjee/` tags (neither the image's nor `ruby_node`'s), no Ruby gem/package versions, no architecture claims, absolute links only.
- Do not use `ruby_node/1.5.0/README.md` as a template for those rules: it predates the spec and hardcodes tags and versions.
- Write in English.

## Dependencies

- None blocking. #166 and #167 follow this one.
- Pushing to Docker Hub is handled separately (#171, release job pushes descriptions); this issue only adds the file. The family push needs #166 and #167 too.

## Responsible agent

`ruby-node`

## Testing

No automated tests. Check the README against the spec's content rules. Verified manually once descriptions are pushed: the `darthjee/rails_bower` Docker Hub page shows this README.

Parent epic: #153
