# Folder Structure

## Project Root

| Directory / File | Description |
|-----------------|-------------|
| `version` | Tracks the latest released version of every image, keyed by image name. |
| `Makefile` | Orchestrates multi-image builds and release targets. |
| `docker-compose.yml` | Service definitions used during image testing. |
| `Dockerfile.test` | Generic Dockerfile used to build test runner images. |
| `bin/` | Build tooling — main CLI (`script.sh`) and helper scripts. |
| `scripts/` | Source for the `scripts` tool image (shared shell scripts copied into other images). |
| `fly/` | Source for the `fly` tool image. |
| `heroku/` | Source for the `heroku` tool image. |
| `experiments/` | Experimental Docker configurations not yet promoted to named images. |
| `readme_files/` | Images and GIFs embedded in `README.md`. |
| `docs/` | Agent and contributor documentation. |
| `ruby_*/` | Development images for various Ruby versions (e.g. `ruby_270/`, `ruby_331/`). |
| `rails_*/` | Rails development images built on top of Ruby images (e.g. `rails_gems/`, `rails_yarn/`). |
| `node/`, `node_mongo/` | Node.js development images. |
| `python_27/`, `python_37/` | Python development images. |
| `django/` | Django development image. |
| `taa/`, `taap/` | TAA project-specific development images. |
| `ruby_plot/` | Ruby image with plotting libraries. |
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
| `docker_login.sh` | Authenticates with Docker Hub. |
| `push_description.sh` | Pushes a README to Docker Hub as the repository description. |

## Image directories (common layout)

Each image directory (e.g. `ruby_270/`) contains one sub-directory per released version:

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
