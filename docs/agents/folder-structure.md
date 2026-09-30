# Folder Structure

## Project Root

| Directory / File | Description |
|-----------------|-------------|
| `version` | Tracks the latest released version of every image, keyed by image name. |
| `Makefile` | Orchestrates multi-image builds and release targets. |
| `docker-compose.yml` | Service definitions used during image testing. |
| `Dockerfile.test` | Generic Dockerfile used to build test runner images. |
| `README.md` | Project overview and usage documentation. |
| `docker.png` | Diagram embedded in `README.md`. |
| `readme_files/` | Images and GIFs embedded in `README.md`. |
| `LICENSE` | Project license. |
| `bin/` | Build tooling — main CLI (`script.sh`) and helper scripts. |
| `scripts/` | Source for the `scripts` tool image (shared shell scripts copied into other images). |
| `fly/` | Source for the `fly` tool image. |
| `heroku/` | Source for the `heroku` tool image. |
| `experiments/` | Experimental Docker configurations not yet promoted to named images. |
| `docs/` | Agent and contributor documentation. |
| `.circleci/` | CircleCI config: tag-triggered `release-<image>` jobs, ordered by image dependency. |
| `.claude/` | Claude Code config: specialist agents (`agents/`), per-agent check scripts (`scripts/`), repo config (`configuration/`) and local state (`state/`). |
| `.github/` | PR and commit message templates, and the Copilot instructions pointer. |
| `ruby_331/`, `ruby_node/` | Ruby development images. |
| `rails_bower/`, `rails_gems/`, `rails_yarn/` | Rails development images built on top of Ruby images. |
| `node/`, `node_mongo/` | Node.js development images. |
| `python_37/` | Python development image. |
| `django/` | Django development image. |
| `taa/`, `taap/` | TAA project-specific development images. |
| `circleci_*/` | CircleCI counterparts of development images (parallel, based on `cimg`). |
| `production_*/` | Production counterparts — stripped of dev dependencies for lightweight deployment. |

## `bin/`

| File | Description |
|------|-------------|
| `script.sh` | Main CLI entry point; delegates to the helpers below. |
| `build.sh` | Builds a Docker image. |
| `release.sh` | Builds and pushes an image to the registry. |
| `test.sh` | Runs tests for an image. |
| `init.sh` | Initialises a new image version directory. |
| `copy_deps.sh` | Copies dependency files into an image directory. |
| `update_deps.sh` | Propagates dependencies from one image to its counterparts. |
| `pre_build.sh` | Validates an image before building. |
| `archive.sh` | Archives an image version that is no longer maintained. |
| `image.sh` | Image actions used locally and by CI: `build`/`tag` (single-platform, `PLATFORM` default `linux/amd64` or an explicit arch), `push` (multi-arch `amd64`+`arm64` via `docker buildx`, skipped if unchanged since the previous tag) and `test`. |
| `docker_login.sh` | Authenticates with Docker Hub. |
| `push_description.sh` | Pushes a README to Docker Hub as the repository description. |

## Image directories (common layout)

Each image directory (e.g. `ruby_331/`) contains one sub-directory per released version:

| Path | Description |
|------|-------------|
| `<image>/<version>/Dockerfile` | Multi-stage build definition for that version. |
| `<image>/<version>/home/` | Files and dependencies copied into the image at build time. |
| `<image>/<version>/test/` | Test scripts that validate the built image. |
| `<image>/<version>/README.md` | (Optional) Description published to Docker Hub. |

## `experiments/`

| Subdirectory | Description |
|--------------|-------------|
| `layers/` | Experiments related to Docker layer optimisation. |
| `override/` | Experiments with Docker image override strategies. |
