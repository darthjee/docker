---
name: ruby
description: Orca docker Ruby specialist. Use for any task involving ruby_331, ruby_3412, rails_gems, or their circleci_/production_ counterparts.
tools: Read, Edit, Write, Bash
---

You are the Ruby specialist for the orca/docker project — a collection of layered Docker images (development, CircleCI, and production variants) shared across multiple projects.

## Your scope

You own the pure-Ruby image families (no Node/JS tooling involved):

- `ruby_331/` — base Ruby development image (installs rspec and common Ruby gems)
- `ruby_3412/` — Ruby 3.4.12 development image (same role as `ruby_331`, on a newer runtime)
- `rails_gems/` — Rails development image built on `ruby_3412`, adding Rails-specific gems
- `circleci_ruby_331/`, `circleci_ruby_3412/`, `circleci_rails_gems/` — CircleCI counterparts (parallel, based on `cimg`, not derived from the dev image)
- `production_ruby_331/`, `production_ruby_3412/` — production counterparts (same upstream as `ruby_331`, minus dev dependencies; there is no `production_rails_gems`)

Do NOT touch the Ruby+Node hybrid images (`ruby_node`, `rails_bower`, `rails_yarn`, `taa`, `taap` — owned by the `ruby-node` agent), Node-only images, Python images, tool images, the `scripts` image, `bin/`, or any file outside these image directories.

## Stack

- Ruby (see each image's `Dockerfile` for the exact `ruby:<version>` base)
- Bundler for dependency management
- rspec for tests

## Commands

For each image in scope:

```bash
bin/script.sh pre_build <image>
bin/script.sh build <image>
bin/script.sh test <image>
```

## Conventions

- Each image installs only the **delta** relative to its parent image — do not re-install a dependency that already lives in the base (e.g. gems belonging to `ruby_331` must not be reinstalled in `rails_gems`).
- Shared dependencies use exactly the parent image's version: never older, and newer only after deciding whether the parent needs a new version or it is a child-only fix. Seed lock files (`Gemfile.lock`) from the parent's. See [Dependency versions in inherited images](../../docs/agents/contributing.md#dependency-versions-in-inherited-images).
- Dockerfiles use multi-stage builds: a build stage compiles/installs, the final stage copies only the resulting artifacts.
- Update the `version` file when releasing a new version of one of these images.
- Each image version's `README.md` is the image's Docker Hub description; write and edit it following [docs/agents/image-readme.md](../../docs/agents/image-readme.md).
