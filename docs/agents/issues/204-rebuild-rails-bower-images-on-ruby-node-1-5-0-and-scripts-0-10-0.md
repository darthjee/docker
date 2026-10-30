# Issue: Rebuild rails_bower images on ruby_node 1.5.0 and scripts 0.11.0

## Description

`rails_bower`, `circleci_rails_bower` and `production_rails_bower` (1.4.0) can no longer be built. Every base image they pin has been removed from Docker Hub (the Hub API returns 404):

| Image | Missing bases |
|---|---|
| `rails_bower/1.4.0` | `darthjee/ruby_node:1.4.0`, `darthjee/scripts:0.3.2` |
| `circleci_rails_bower/1.4.0` | `darthjee/circleci_ruby_node:1.4.0`, `darthjee/scripts:0.3.2` |
| `production_rails_bower/1.4.0` | `darthjee/production_ruby_node:1.4.0`, `darthjee/scripts:0.3.2` |

Split out of #202, which now covers only `taap`.

Responsible agent: `ruby-node`.

## Expected Behavior

- `rails_bower`, `circleci_rails_bower` and `production_rails_bower` have a new `1.5.0` version, and `version` pins `rails_bower=1.5.0`.
- `bin/script.sh build rails_bower` builds all three images.
- The new versions build on both `linux/amd64` and `linux/arm64`.
- The `1.4.0` folders stay in the repo, unchanged.

## Solution

Run `bin/script.sh init rails_bower 1.5.0`. Pass the version explicitly, because the default would bump only the patch number, to 1.4.1. `init` copies `1.4.0` into `1.5.0` for all three variants and rewrites the `darthjee/*` `FROM` lines to the versions in the `version` file:

- `darthjee/ruby_node:1.5.0` (and its circleci/production versions). Compared with 1.4.0, the only changes are `ruby_331` 1.0.0 → 1.1.1 (Bundler 2.5.11) and Node 20 → 22. Both are still Ruby 3.3.1, which is what the `rails_bower` Gemfile asks for.
- `darthjee/scripts:0.11.0`, the current pinned version. `bundle_builder.sh` and `bower_builder.sh` are identical in 0.10.0 and 0.11.0. Since 0.4.3 they only gained quoting fixes, and the paths they write to are the same, so the current `COPY --from=builder` lines should still work.

Additional changes in the new `1.5.0` folders:

- `production_rails_bower/1.5.0/Dockerfile`: replace the deprecated `bundle_builder.sh --without development test` with `RUN bundle config set without 'development test'` followed by a plain `RUN /bin/bash bundle_builder.sh`. This matches `production_ruby_331`.
- Update each image's `README.md` in the new version folder to match the new contents (Node 22, base versions), following the image README conventions in `docs/agents/image-readme.md`.

Leave the `1.4.0` folders as they are; do not remove them.
