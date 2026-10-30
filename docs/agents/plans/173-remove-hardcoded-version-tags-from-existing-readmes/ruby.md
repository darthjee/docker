# Ruby Plan: Remove hardcoded version tags from existing READMEs

Main plan: [plan.md](plan.md)

## Shared contracts

- Replace `darthjee/<image>:<tag>` with `darthjee/<image>:<version>` (literal `<version>`).
- Insert ` (see the available tags at https://hub.docker.com/r/darthjee/<image>/tags)` before the final colon of the first sentence under `## How to use`, using the README's own image name.
- Change nothing else.

## Implementation Steps

### Step 1 — ruby_331 family

In each README, the `FROM` line in *How to use* is the only hardcoded tag (`:1.1.0`):

- `ruby_331/1.1.1/README.md` — `FROM darthjee/ruby_331:1.1.0` → `FROM darthjee/ruby_331:<version>`; intro "...reference it in your `Dockerfile`:" gets the pointer to `https://hub.docker.com/r/darthjee/ruby_331/tags`.
- `circleci_ruby_331/1.1.1/README.md` — `FROM darthjee/circleci_ruby_331:1.1.0` → `:<version>`; intro "...reference it in your `.circleci/config.yml` or `Dockerfile`:" gets the pointer to `.../darthjee/circleci_ruby_331/tags`.
- `production_ruby_331/1.1.1/README.md` — `FROM darthjee/production_ruby_331:1.1.0` → `:<version>`; intro gets the pointer to `.../darthjee/production_ruby_331/tags`.

### Step 2 — rails_gems family

Same change, tag `:2.1.0`:

- `rails_gems/2.1.1/README.md` — `FROM darthjee/rails_gems:2.1.0` → `:<version>`; pointer to `.../darthjee/rails_gems/tags`.
- `circleci_rails_gems/2.1.1/README.md` — `FROM darthjee/circleci_rails_gems:2.1.0` → `:<version>`; pointer to `.../darthjee/circleci_rails_gems/tags`.

## Files to Change

- `ruby_331/1.1.1/README.md`
- `circleci_ruby_331/1.1.1/README.md`
- `production_ruby_331/1.1.1/README.md`
- `rails_gems/2.1.1/README.md`
- `circleci_rails_gems/2.1.1/README.md`

## Notes

- `README.md` is not copied into any image (Dockerfiles only `COPY home/*`), so no version bump or rebuild is needed; the Docker Hub description is updated on the next release tag.
- Do not touch older version folders (e.g. `ruby_331/1.1.0/`).
