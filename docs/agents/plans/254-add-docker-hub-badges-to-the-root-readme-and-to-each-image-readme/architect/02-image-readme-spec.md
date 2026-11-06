# Image README spec

Update `docs/agents/image-readme.md` so every image README includes the badge:

- **Skeleton:** add the badge line between the `=` underline and `## About the image`:

  ````markdown
  darthjee/<image>
  ================

  [![docker](https://img.shields.io/docker/v/darthjee/<image>.svg?logo=docker&label=<image>&sort=semver)](https://hub.docker.com/r/darthjee/<image>)

  ## About the image
  ````

- **Skeleton bullets:** add one saying the Docker Hub version badge comes right under the title, in exactly that format (public `/r/` link, `label=<image>`, `sort=semver`, version badge only). Say it's the same badge as in the root README `## Images` list, and that `bin/archive.sh` relies on the `(https://hub.docker.com/r/darthjee/<image>)` link.
- **Versions and architectures:** add a sentence saying the badge is allowed: it shows the live Docker Hub version and contains no hardcoded tag, so `init` copies it without it going stale.

Keep the rest of the doc unchanged.

## Files to Change
- `docs/agents/image-readme.md` — badge added to the skeleton and its rules.
