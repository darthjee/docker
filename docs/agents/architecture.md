# Architecture

## Overview

This repository is a collection of Docker images shared across multiple projects. Rather than a single application, it is a catalogue of versioned image sources organized by category. Each image only installs the **difference** relative to its parent, so projects share common Docker layers and minimize redundant storage and build time.

Images fall into four categories:
- **Tool images** — standalone utilities with no CircleCI or production counterparts.
- **Development images** — full development environments.
- **CircleCI images** (`circleci_*`) — parallel CI-optimised variants based on `cimg`, not derived from the dev image.
- **Production images** (`production_*`) — parallel lightweight variants that share the same upstream base as their dev counterpart but omit dev-only dependencies.

## Image Hierarchy

Development, CircleCI, and production images mirror each other in parallel hierarchies:

```
ruby:3.3.1 (upstream)
├── ruby_331/          ← dev
│   └── ruby_node/     ← dev, adds Node
├── circleci_ruby_331/ ← CI (based on cimg, not ruby_331)
│   └── circleci_ruby_node/
└── production_ruby_331/ ← prod (same upstream as ruby_331, minus dev deps)
    └── production_ruby_node/
```

Each image in a hierarchy installs only the delta relative to its parent, so layers accumulate rather than duplicate.

## Multi-Stage Builds

Dockerfiles use multi-stage builds to avoid polluting the final image with build-time artifacts (source files, logs, compilers). An intermediate build stage performs all compilation and installation; only the results are copied into the final image.

This also collapses many install commands into fewer layers, which matters for platforms with a layer cap (e.g. Heroku enforces a 40-layer limit).

**Pitfall:** Docker has no concept of deleting a file — removing or overwriting a file in a later layer still stores it again. Multi-stage builds mitigate this, but dependency copy steps must be carefully scoped to avoid re-copying files that already exist in the base image.

## `scripts` Image

The `scripts` image acts as a shared script repository. Its scripts are either:
- Copied into other images during their Docker build (`COPY --from=scripts ...`), or
- Sourced during the build process itself in a multi-stage step.

Key script: `scripts/<version>/home/sbin/docker_hub.sh` — handles Docker Hub authentication and README publishing.

## Build Tooling (`bin/`)

`bin/script.sh` is the single CLI entry point. It delegates to focused helper scripts:

| Helper | Responsibility |
|--------|---------------|
| `init.sh` | Scaffold a new image version directory. |
| `copy_deps.sh` | Copy dependency files into an image. |
| `update_deps.sh` | Propagate deps from a dev image to its CI/prod counterparts. |
| `build.sh` | Build a Docker image (and its circleci_/production_ variants), fetching or building its `darthjee/*` bases first. Stops at the first failure and exits non-zero. |
| `release.sh` | Build and push to the registry. |
| `test.sh` | Run the image's test suite. |
| `pre_build.sh` | Pre-build validation. |
| `archive.sh` | Archive an image version that is no longer maintained. |
| `image.sh` | Per-image actions (`build`, `tag`, `push`, `test`, `description`) used locally and by CI. |
| `push_description.sh` | Push a README to Docker Hub. |

## Versioning

The `version` file at the repo root is the single source of truth for the latest released version of each image. It is organized by category (Tools, Development, CircleCI, Production), with one `name=version` entry per image.

## Release Pipeline

Releases are triggered by pushing a git tag. `.circleci/config.yml` defines one `release-<image>` job per image (tag-only filters), chained with `requires:` so parents release before their children (e.g. `release-ruby_node` requires `release-ruby_331`). Each job sets up QEMU and a `docker buildx` builder, runs `bin/image.sh push <image>`, then pushes the image's README as its Docker Hub description with `bin/image.sh description <image>` (a separate step, so a skipped image push does not skip it).

`bin/image.sh` actions:

| Action | Behavior |
|--------|----------|
| `build <image> [arch]` | Local single-platform build (`$PLATFORM`, default `linux/amd64`, or `linux/<arch>` with a `-<arch>` tag suffix), tagged `latest` and `<version>`. Exits non-zero (without tagging `<version>`) if `docker build` fails. |
| `tag <image> [arch]` | Alias of `build`. |
| `push <image>` | Skips the image if `<image>/<version>/`, ignoring `README.md` and `test/`, is unchanged since the previous tag (a README-only or test-only change never re-pushes the image); otherwise logs in and runs `docker buildx build --platform linux/amd64,linux/arm64 --push`, publishing a multi-arch manifest tagged `<version>` and `latest`. |
| `test <image>` | Builds and runs the `docker-compose.yml` `test` service against the image (see [Testing](#testing)); exits non-zero if the test-image build or the tests fail. |
| `description <image>` | Skips if `<image>/<version>/` (README included) is unchanged since the previous tag; otherwise pushes `<image>/<version>/README.md` as the Docker Hub description of that single image (no `circleci_`/`production_` fan-out), via `push_description_image`. |

## Building

`bin/script.sh build <images>` builds each image and its `circleci_`/`production_` variants in turn. Before building, `fetch_bases` pulls every pinned `darthjee/*` base from the image's `FROM` lines; if a pull fails it falls back to `bin/script.sh build <base>`, which builds the base at its **current** version, then checks that the pinned tag now exists locally (`docker image inspect`). If it doesn't (the pin is older than the current version), it prints an error and fails. Any failed base fetch or `bin/image.sh build` stops the whole run and `bin/script.sh build` exits non-zero.

## Testing

Each image version may contain a `test/` directory with a `test.sh` entry point and `subtests/*.sh`. Tests are run via `bin/script.sh test <images>`, which calls `bin/image.sh test` for each image and its `circleci_`/`production_` variants and exits non-zero when any of them fails.

`bin/image.sh test <image>`:

1. If `<image>/<version>/test/` doesn't exist, prints `no tests for <image>` and returns 0 (e.g. `node`, `node_mongo`, `python_37`, `django` and their variants).
2. Builds the `docker-compose.yml` `test` service from `<image>/<version>/test/Dockerfile` when the version ships one, otherwise from the root `Dockerfile.test` (via the `TEST_DOCKERFILE` variable, same build context and args, for the same `PLATFORM` that `bin/image.sh build` uses). A failed build fails the test.
3. Runs `docker-compose run --rm test`, i.e. the service's command `/home/test/test.sh`, and returns its exit status.

`Dockerfile.test` copies both `<image>/<version>/home` and `<image>/<version>/test`, so a version with no `home/` folder (e.g. `ruby_node`) ships its own `test/Dockerfile` that only copies `test/`. `scripts` ships its own too, because the alpine image has no `app` user.

Every `test/test.sh` runs all of `/home/test/subtests/*.sh`, counts failures, and exits 1 if any failed (see `scripts/0.11.0/test/test.sh`).

Changes under `<image>/<version>/test/` don't trigger a re-push of that version on release (see `push` above), so fixing or extending tests in a published version folder is a same-version change.
