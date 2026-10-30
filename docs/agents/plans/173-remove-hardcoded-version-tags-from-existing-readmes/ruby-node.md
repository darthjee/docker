# Ruby-Node Plan: Remove hardcoded version tags from existing READMEs

Main plan: [plan.md](plan.md)

## Shared contracts

- Replace `darthjee/<image>:<tag>` with `darthjee/<image>:<version>` (literal `<version>`), in `FROM`, CircleCI `- image:` and `docker pull` lines.
- Insert ` (see the available tags at https://hub.docker.com/r/darthjee/<image>/tags)` before the final colon of the first sentence under `## How to use`, using the README's own image name.
- Change nothing else.

## Implementation Steps

### Step 1 — rails_yarn family (tag `:1.0.1`)

- `rails_yarn/1.1.0/README.md` — 2× `FROM darthjee/rails_yarn:1.0.1` and `docker pull darthjee/rails_yarn:1.0.1` → `:<version>`; intro "Reference this image in your `Dockerfile`:" gets the pointer to `https://hub.docker.com/r/darthjee/rails_yarn/tags`.
- `circleci_rails_yarn/1.1.0/README.md` — `FROM`, `- image:` and `docker pull` with `:1.0.1` → `:<version>`; intro "Reference this image in your `.circleci/config.yml` or `Dockerfile`:" gets the pointer to `.../darthjee/circleci_rails_yarn/tags`.
- `production_rails_yarn/1.1.0/README.md` — 2× `FROM` and `docker pull` with `:1.0.1` → `:<version>`; intro "Reference this image in your production `Dockerfile`:" gets the pointer to `.../darthjee/production_rails_yarn/tags`.

### Step 2 — ruby_node and taa families (tag `:1.4.2`)

- `ruby_node/1.5.0/README.md` — 2× `FROM` and `docker pull` → `:<version>`; pointer to `.../darthjee/ruby_node/tags`.
- `circleci_ruby_node/1.5.0/README.md` — `FROM`, `- image:` and `docker pull` → `:<version>`; pointer to `.../darthjee/circleci_ruby_node/tags`.
- `production_ruby_node/1.5.0/README.md` — `FROM` and `docker pull` → `:<version>`; pointer to `.../darthjee/production_ruby_node/tags`.
- `taa/1.5.0/README.md` — 2× `FROM` and `docker pull` → `:<version>`; pointer to `.../darthjee/taa/tags`.
- `circleci_taa/1.5.0/README.md` — `FROM`, `- image:` and `docker pull` → `:<version>`; pointer to `.../darthjee/circleci_taa/tags`.
- `production_taa/1.5.0/README.md` — 2× `FROM` and `docker pull` → `:<version>`; pointer to `.../darthjee/production_taa/tags`.

## Files to Change

- `rails_yarn/1.1.0/README.md`
- `circleci_rails_yarn/1.1.0/README.md`
- `production_rails_yarn/1.1.0/README.md`
- `ruby_node/1.5.0/README.md`
- `circleci_ruby_node/1.5.0/README.md`
- `production_ruby_node/1.5.0/README.md`
- `taa/1.5.0/README.md`
- `circleci_taa/1.5.0/README.md`
- `production_taa/1.5.0/README.md`

## Notes

- The `## Variants` tables reference images without tags (e.g. `` `darthjee/rails_yarn` ``) and stay unchanged.
- Pinned gem/package versions (e.g. **Yarn** (1.22.22), **azeroth** (2.0.0)) are image contents, not tags — leave them.
- `README.md` is not copied into any image, so no version bump or rebuild is needed.
- Do not touch `taap`/`rails_bower` READMEs (already use `<version>`) or older version folders.
