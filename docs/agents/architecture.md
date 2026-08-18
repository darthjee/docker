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
| `build.sh` | Build a Docker image. |
| `release.sh` | Build and push to the registry. |
| `test.sh` | Run the image's test suite. |
| `pre_build.sh` | Pre-build validation. |
| `archive.sh` | Archive an image version that is no longer maintained. |
| `image.sh` | Shared helpers for resolving image name/version and target platform. |
| `push_description.sh` | Push a README to Docker Hub. |

## Versioning

The `version` file at the repo root is the single source of truth for the latest released version of each image. It is organized by category (Tools, Development, CircleCI, Production), with one `name=version` entry per image.

## Testing

Each image version contains a `test/` directory with a `test.sh` script. Tests are run via `bin/script.sh test <image>` and use `docker-compose.yml` + `Dockerfile.test` to spin up a container and validate it.
