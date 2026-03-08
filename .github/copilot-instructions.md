# GitHub Copilot Instructions

## Language

All code, comments, descriptions, pull requests, and documentation in this repository must be written in **English**.

## Project Overview

This repository is a collection of Docker images used across multiple projects. The images come pre-installed with common dependencies so that individual projects only need to install their own specific additions on top of a shared base.

## Image Categories

There are four categories of images:

- **Tool images** – Utility images (e.g. `fly`, `scripts`, `heroku`) that have no CircleCI or production counterparts.
- **Development images** – Full development environments (e.g. `ruby_270`, `rails_gems`, `node`, `django`, `taa`, `taap`).
- **CircleCI images** – Variants prefixed with `circleci_` (e.g. `circleci_ruby_270`), optimized for running tests on circleci.com. They are **parallel** images based on `cimg` (CircleCI base images), not built on top of the development image.
- **Production images** – Variants prefixed with `production_` (e.g. `production_ruby_270`), stripped of development dependencies to be lightweight and suitable for running in production servers. They are **parallel** images that share the same base image as their development counterpart but do not install development dependencies.

Not every development image has a CircleCI or production counterpart.

## Image Hierarchy and Dependency Installation

Images are layered so that each image only installs the **difference** relative to its parent. For example:

- Ruby images install rspec and common Ruby gems.
- Rails images are built **on top of** Ruby images and add Rails-specific dependencies.
- CircleCI and production images **mirror** this same hierarchy in parallel. For example, `ruby_node` is based on `ruby_331`, while `production_ruby_node` is based on `production_ruby_331`. Both `ruby_331` and `production_ruby_331` share the same upstream base image (e.g. `ruby:3.3.1`).
- Each image in a hierarchy only installs the **difference** relative to its parent, so projects share common Docker layers.

## `scripts` Image

The `scripts` image is a repository of shared shell scripts. These scripts are either:

- **Copied into other images** during their Docker build, or
- **Used during the image build process** itself (e.g. sourced in a multi-stage build step).

## `version` File

The `version` file at the root of the repository stores the latest released version for each image, organised by category:

```
# Tools
fly=0.0.1
scripts=0.6.0
...
# Development
ruby_270=1.4.0
...
# CircleCI
circleci_ruby_270=1.4.0
...
# Production
production_ruby_270=1.4.0
...
```

## `bin/script.sh` – Build Tooling

The `bin/script.sh` script is the main entry point for managing images. It delegates to helper scripts inside `bin/`:

| Command | Description |
|---|---|
| `bin/script.sh init <image> [new_version]` | Initialise a new image version |
| `bin/script.sh copy_deps <image>` | Copy dependency files to the image |
| `bin/script.sh update_deps <image> <source>` | Copy dependencies from one image to another (e.g. from a dev image to its circleci/production counterparts) |
| `bin/script.sh build <images>` | Build one or more images |
| `bin/script.sh release <images>` | Build and push one or more images to the registry |
| `bin/script.sh test <images>` | Run tests for one or more images |
| `bin/script.sh pre_build <images>` | Validate an image before building |

Helper scripts in `bin/`: `build.sh`, `release.sh`, `test.sh`, `init.sh`, `copy_deps.sh`, `update_deps.sh`, `pre_build.sh`.

## Repository Structure

```
.
├── version                  # Latest version of every image
├── Makefile                 # Orchestrates multi-image builds
├── docker-compose.yml       # Test service definitions
├── Dockerfile.test          # Generic test image builder
├── bin/
│   └── script.sh            # Main CLI for init/build/release/test
├── scripts/                 # scripts image source
├── fly/                     # fly tool image source
├── heroku/                  # heroku tool image source
├── ruby_270/                # Development image source
│   └── <version>/
│       ├── Dockerfile
│       ├── home/
│       └── test/
├── circleci_ruby_270/       # CircleCI counterpart
├── production_ruby_270/     # Production counterpart
└── ...                      # Other images follow the same pattern
```

Each image folder contains one sub-directory per released version. Each version directory holds:
- `Dockerfile` – Multi-stage build definition.
- `home/` – Files and dependencies to be copied into the image.
- `test/` – Tests and a `test.sh` script for validating the image.
- `README.md` – (optional) Documentation for the image version, published to Docker Hub as the repository's full description.

## Docker Hub Description Publishing

Each image version may include a `README.md` file (e.g. `scripts/0.6.0/README.md`). This file is published to Docker Hub as the repository's full description using the `docker_hub.sh` script provided by the `scripts` image.

The script is located at `scripts/<version>/home/sbin/docker_hub.sh` and supports the following actions:

| Action | Description |
|---|---|
| `docker_hub.sh login` | Authenticates with Docker Hub and exports a JWT token |
| `docker_hub.sh push_description <repo> <readme_file>` | Pushes the README to Docker Hub (requires prior login) |
| `docker_hub.sh login_and_push_description <repo> <readme_file>` | Authenticates and pushes the README in one step |
| `docker_hub.sh push <image>` | Pushes a Docker image to the registry |

To publish a README, the `DOCKER_HUB_USERNAME` and `DOCKER_HUB_PASSWORD` environment variables must be set. Example usage:

```bash
docker_hub.sh login_and_push_description darthjee/scripts scripts/0.6.0/README.md
```

> **Note:** Neither the `bin/` scripts nor the `Makefile` publish the Docker Hub description. This step is performed separately using `docker_hub.sh`.
