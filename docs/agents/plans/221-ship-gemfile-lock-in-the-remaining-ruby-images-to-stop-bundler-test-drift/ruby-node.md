# Plan: Ship Gemfile.lock in the remaining Ruby images to stop bundler test drift

Issue: [221-ship-gemfile-lock-in-the-remaining-ruby-images-to-stop-bundler-test-drift.md](../../issues/221-ship-gemfile-lock-in-the-remaining-ruby-images-to-stop-bundler-test-drift.md)

## Overview
Release new versions of `rails_yarn`, `taa`, `taap` and `rails_bower` (+circleci/production) that ship a `home/Gemfile.lock`, built on the newest parents and released in chain order. Replace the `bundle lock --local` workarounds in the `taa` bundler subtests with a plain check against the shipped lockfile. Make the `production_rails_bower` check explicitly scoped to the installed groups.

## Context
- Without a lockfile, `bundle check` re-resolves unpinned transitive dependencies against live rubygems.org and fails once a newer release appears (see #211, #212).
- #211 shipped lockfiles in `ruby_331` 1.1.2/1.2.0 and `rails_gems` 2.1.2/2.2.0. Use those as the reference: `ruby_331/1.2.0/home/Gemfile.lock`, `circleci_ruby_331/1.2.0/home/Gemfile.lock`, `production_ruby_331/1.2.0/home/Gemfile.lock`.
- Each image's `COPY home/* /home/app/app/` (or the circleci equivalent) already copies every file in `home/`, so `bundle_builder.sh`'s `bundle install` honours a `Gemfile.lock` placed there. No Dockerfile change is needed for the lockfile itself.
- `bin/script.sh init <image> [version]` copies the current version folder for all three variants, bumps the `version` file and rewrites every `darthjee/<img>:<ver>` `FROM` to the version currently in `version`. Running `init` in chain order therefore picks up the new parents automatically.
- Current state: `rails_yarn` 1.2.0 is on `ruby_331:1.2.0`/`scripts:0.11.0`. `taa` 1.6.0 is on `rails_yarn:1.2.0`/`scripts:0.11.0`. `taap` 1.5.0 is on `taa:1.5.0`/`scripts:0.10.0` (but `circleci_taap` is already on `circleci_taa:1.6.0`/`scripts:0.11.0`). `rails_bower` 1.5.0 is on `ruby_node:1.5.0`/`scripts:0.11.0`.

## Lockfile generation (applies to every step)
Generate each variant's lockfile **inside that variant's own parent image** (`bin/script.sh pre_build <image>` opens a shell in the first `FROM` with `home/` mounted). For variants whose second `FROM` is the real base, run the parent image directly, e.g. `docker run --rm -it -v $PWD/<image>/<version>/home:/home/app/app darthjee/<parent>:<ver> bash`, mounting at `/home/circleci/project` for circleci.
- Seed the lockfile with the parent's lockfile: copy the matching variant's parent `Gemfile.lock` into `home/` before running `bundle lock`. Bundler then keeps the gems the parent already installed at the same versions, which keeps the image a pure delta. Seeds: `rails_yarn` from `ruby_331` 1.2.0, `taa` from the new `rails_yarn`, `taap` from the new `taa`, and `rails_bower` from `ruby_331` 1.2.0 (`ruby_node` has no lockfile, and its Gemfile is identical to `ruby_331`'s).
- Use the bundler that the image actually runs. That is 4.0.23 for dev/production (`gem update --system` overrides the 2.5.11 default) and cimg's 2.6.8 for circleci, so there is no runtime auto-switch. Check `BUNDLED WITH` against the seed.
- Restrict platforms to `x86_64-linux`, `x86_64-linux-gnu`, `aarch64-linux`, `aarch64-linux-gnu` (`bundle lock --add-platform ...` / `--remove-platform ruby` as needed) so multi-arch buildx builds resolve.
- Production variants lock **all** groups (same as `production_ruby_331`). The installed subset is controlled by `bundle config set without 'development test'` / `BUNDLE_WITHOUT`.

## Steps

- [01 — rails_yarn 1.2.1 with Gemfile.lock](ruby-node/01-rails-yarn.md)
- [02 — taa 1.6.1 with Gemfile.lock and plain bundler checks](ruby-node/02-taa.md)
- [03 — taap 1.6.0 on taa 1.6.1 and scripts 0.11.0](ruby-node/03-taap.md)
- [04 — rails_bower 1.6.0 on ruby_node 1.6.0](ruby-node/04-rails-bower.md)

## CI Checks
For each image, run it for all three variants:
- `bin/script.sh build <image> circleci_<image> production_<image>`
- `bin/script.sh test <image> circleci_<image> production_<image>`

CI release jobs (`.circleci/config.yml`: `release-<image>`, `release-circleci_<image>`, `release-production_<image>`) release whatever version `version` lists. The new versions must also build for `linux/arm64`.

## Notes
- Order matters: `init` each image only after its parent's new version is in `version` (rails_yarn → taa → taap). `rails_bower` is independent.
- Do not modify existing version folders. Only add new ones.
- Do not touch `ruby_node`, `ruby_331`, `rails_gems`, `scripts` or `bin/`.
- After `init`, check each new `README.md` for any mention of the old parent versions and update it per `docs/agents/image-readme.md` (no hardcoded version tags, per #173).
- If a seeded `bundle lock` has to move a gem that the parent already installed, stop and report it rather than letting the child re-install a different version.
