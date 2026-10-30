# Ruby-node Plan: Rebuild rails_bower images on ruby_node 1.5.0 and scripts 0.11.0

Main plan: [plan.md](plan.md)

## Overview
Use `bin/script.sh init rails_bower 1.5.0` to scaffold `1.5.0` for all three variants with `FROM` lines updated automatically. Then make one production-specific Bundler change, review the READMEs, and build and test.

## Context
- Every base the `1.4.0` images pin (`darthjee/{,circleci_,production_}ruby_node:1.4.0` and `darthjee/scripts:0.3.2`) is gone from Docker Hub.
- `version` currently pins `scripts=0.11.0`, `ruby_node=1.5.0` and `rails_bower=1.4.0`.
- `bin/init.sh` copies `<image>/<current>` to `<image>/<new>` for the plain, `circleci_` and `production_` variants. It sets `rails_bower=<new>` in `version` and rewrites every `FROM darthjee/<img>:<v>` to the version `version` pins. Without an explicit version it would only bump the patch number (1.4.1), so pass `1.5.0`.
- `ruby_node` 1.5.0 is `ruby_331` 1.1.1 (Ruby 3.3.1, Bundler 2.5.11) plus Node 22.
- `bundle_builder.sh` and `bower_builder.sh` are identical in scripts 0.10.0 and 0.11.0, and still write to `$HOME_DIR/bundle` and `$HOME_DIR/bower`. The existing `COPY --from=scripts` and `COPY --from=builder` paths therefore stay valid.

## Implementation Steps

### Step 1 — Scaffold 1.5.0 and update the production Bundler config
1. Run `bin/script.sh init rails_bower 1.5.0` from the repo root.
2. Verify that the three new Dockerfiles start with `FROM darthjee/scripts:0.11.0 as scripts` and `FROM darthjee/{,circleci_,production_}ruby_node:1.5.0 as base`, and that `version` has `rails_bower=1.5.0`.
3. In `production_rails_bower/1.5.0/Dockerfile`, replace `RUN /bin/bash bundle_builder.sh --without development test` with:
   ```dockerfile
   RUN bundle config set without 'development test'
   RUN /bin/bash bundle_builder.sh
   ```
   This matches `production_ruby_331`. Bundler 2.5 deprecates the `--without` flag.
4. Review the three copied `README.md` files against the image README conventions (`docs/agents/image-readme.md`). They describe the base images without pinning versions or a Node version, so no change is expected. Update them only if something in the new contents makes them inaccurate.
5. Leave `*/1.4.0` untouched.

### Step 2 — Build and test
Run `bin/script.sh build rails_bower` and `bin/script.sh test rails_bower` for all three variants, or the agent check script below. Fix any build breakage that comes from the new bases, limited to the `1.5.0` folders.

## Files to Change
- `rails_bower/1.5.0/` (new, copied from 1.4.0): updated `FROM` lines
- `circleci_rails_bower/1.5.0/` (new, copied from 1.4.0): updated `FROM` lines
- `production_rails_bower/1.5.0/` (new, copied from 1.4.0): updated `FROM` lines, `bundle config set without` in the Dockerfile
- `version`: `rails_bower=1.5.0`

## CI Checks
- `rails_bower` family: `.claude/scripts/check_ruby-node.sh` (builds and tests `ruby_node rails_bower rails_yarn taa taap`). For a faster loop, run `bin/script.sh build rails_bower && bin/script.sh test rails_bower`.
- The release jobs `release-rails_bower`, `release-circleci_rails_bower` and `release-production_rails_bower` (`.circleci/config.yml`) run `bin/image.sh push` with buildx for `linux/amd64` and `linux/arm64`. They only run on tags, so verify arm64 locally with buildx if possible.

## Notes
- `circleci_rails_bower` runs `apt-get install telnet` without a preceding `apt-get update`. If the new base has cleaned its apt lists, change it to `apt-get update && apt-get install -y telnet`.
- `chown app.app` / `chown circleci.circleci` (dot separator) is deprecated in newer coreutils and prints a warning, but still works. Switch to `:` only if it breaks.
- `npm install bower -g` on Node 22: bower is deprecated upstream but still installs. Watch for install failures.
- The issue file name still says `scripts-0-10-0`. The issue now targets scripts 0.11.0.
