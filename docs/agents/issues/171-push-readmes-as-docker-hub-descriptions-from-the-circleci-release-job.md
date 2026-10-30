# Issue: Push READMEs as Docker Hub descriptions from the CircleCI release job

## Description

Push each image's `README.md` to Docker Hub as its repository description automatically, from the CircleCI `release` job in `.circleci/config.yml`, which runs once per image on every git tag. Today descriptions are only pushed manually with `bin/script.sh push_description <images>` (`bin/push_description.sh`).

## Problem

- `push_description_images` always processes the image plus its `circleci_`/`production_` counterparts, so calling it from the per-image release job would push each family several times and fail on any missing counterpart.
- A missing `<image>/<version>/README.md` makes it `exit 1`; today `ruby_base/0.2.2` and `production_taap/1.4.2` have no README.
- Errors pass silently: `curl` does not check the HTTP status of the PATCH, and `docker_login` does not check that a token came back (`jq` prints `null` on failure).
- The image push's `skip_if_unchanged` counts any file in `<image>/<version>/`, so a README-only commit rebuilds and re-pushes the image under the same version tag.

## Solution

- **Single-image entry point:** add a way to push the description of exactly one image (no `circleci_`/`production_` fan-out). Keep `bin/script.sh push_description <images>` working as it does today.
- **Release step:** add a `run` step to the `release` job, after `bin/image.sh push << parameters.image >>`, that pushes the description of `<< parameters.image >>` only.
- **Skip when unchanged:** the description step respects `skip_if_unchanged`. It runs only when `<image>/<version>/` (README included) changed since the previous tag, and otherwise logs a skip and exits 0.
- **Image push ignores README.md:** the image push's `skip_if_unchanged` excludes `README.md` from its diff, so a README-only change updates the description without rebuilding or re-pushing the image.
- **Missing README:** log a warning and exit 0, so a release is never blocked by a missing README.
- **API errors fail the job:** fail (non-zero exit, clear message) when the login returns no token or the PATCH returns a non-2xx status. The image is already pushed at that point, so the job can simply be rerun.
- **Credentials:** reuse `DOCKER_HUB_USERNAME`/`DOCKER_HUB_PASSWORD`, already available to the release job, through `bin/docker_login.sh`.

## Notes

- Because the step respects `skip_if_unchanged`, READMEs that landed before the latest tag are not pushed by CI until their folder changes again. Publish those once by hand with `bin/script.sh push_description <images>`.

## Out of scope

- Writing the missing READMEs (separate sub-issues of #153).
- Changing the `scripts` image's own `docker_hub.sh`.

## Responsible agent

`architect` (root-level `bin/` scripts and `.circleci/config.yml`).

## Testing

No automated tests. Check locally with `bash -n` and by running the new entry point against an image without a README (warns, exits 0). Verify after the next release tag: images whose folder changed get their description updated, a README-only change does not re-push the image, and images without a README log a warning while the job still succeeds.

Parent epic: #153
