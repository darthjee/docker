# Issue: Add Docker Hub badges to the root README and to each image README

## Description

Add a Docker Hub version badge (shields.io) for every image published by this repo:

1. In the root `README.md`, in the `## Images` list.
2. In each image's `<image>/<version>/README.md`, which `bin/push_description.sh` publishes as the Docker Hub description, so the badge also shows on Docker Hub.

## Problem

The root `README.md` `## Images` list hardcodes `[<image>:<version>](…)` links that no script keeps up to date — `bin/script.sh init` never touches the root README — so most of them are stale (e.g. `node:0.2.1` while `version` says `0.2.4`). The image READMEs on Docker Hub show no version at all, by design (`docs/agents/image-readme.md` forbids hardcoded `darthjee/` tags).

## Expected Behavior

- Every image in the root `version` file (33 images) has a live version badge in the root README and in its current image README.
- The badges always show the latest released version without any manual or scripted update.
- `bin/archive.sh` keeps removing an archived image's line from the root README.
- New image READMEs include the badge, as required by `docs/agents/image-readme.md`.

## Solution

### Scope

#### In scope

1. **Root `README.md` — `## Images` list:** one badge per image listed in the root `version` file, across all four groups (Tools, Development, Circleci, Production) — 33 images, including the deprecated `python_37` and `circleci_python_37` (keep their "(deprecated, use …)" note next to the badge).
   - The badge **replaces** the current hardcoded `[<image>:<version>](…)` links, which are stale (e.g. `node:0.2.1` while `version` says `0.2.4`); the badge shows the live version and itself links to Docker Hub.
2. **Image READMEs:** add the badge to `<image>/<version>/README.md` for every image, **only in the folder the `version` file points to** (the one `bin/push_description.sh` reads). The badge is version-agnostic, so `bin/script.sh init` carries it to future versions without going stale.
3. **`docs/agents/image-readme.md`:** update the skeleton (and the related rules) so every new image README includes the badge.
4. **`bin/archive.sh`:** update `remove_from_readme` so it still removes an archived image's line from the root README once that line is a badge (see [Root README layout](#root-readme-layout)).
5. **Publishing (manual follow-up by the repo owner, not part of the implementation):** after merge, the owner pushes the updated descriptions to Docker Hub by hand with `bin/script.sh push_description <image>` (per dev image, which also pushes its `circleci_`/`production_` counterparts, plus `scripts`), since the CI `release` job only pushes descriptions for image folders changed since the previous tag. The implementation does not run it; the PR description lists the exact `bin/script.sh push_description …` commands to run.

#### Out of scope

- READMEs in older version folders (never edited, nothing reads them).
- Any Dockerfile or image-content change: this is README-only — no `bin/script.sh init`, no `version` bump.
- Fixing other known deviations in image READMEs (hardcoded tags, etc.).

### Badge format

One badge per image, the same in the root README and in the image README:

```markdown
[![docker](https://img.shields.io/docker/v/darthjee/<image>.svg?logo=docker&label=<image>&sort=semver)](https://hub.docker.com/r/darthjee/<image>)
```

- **Link target:** the public Docker Hub page `https://hub.docker.com/r/darthjee/<image>` (not the owner-only `/repository/docker/darthjee/<image>/general` dashboard from the original example). It is consistent with the links already used in image READMEs, and `bin/archive.sh` relies on it to find the root README line.
- **Label:** the image name (`label=<image>`), so root README entries remain identifiable without any other text.
- **Version sort:** `sort=semver`, since every image is pushed with both a `<version>` and a `latest` tag.
- **Extra badges:** none — version badge only (no pulls / image-size badges).

### Root README layout

Keep the existing `## Images` list and its four groups (Tools, Development, Circleci, Production); each entry's hardcoded `[<image>:<version>](…)` link is **replaced by the badge**:

```markdown
## Images

#### Tools
  - [![docker](https://img.shields.io/docker/v/darthjee/scripts.svg?logo=docker&label=scripts&sort=semver)](https://hub.docker.com/r/darthjee/scripts)
### Development
  - [![docker](https://img.shields.io/docker/v/darthjee/node.svg?logo=docker&label=node&sort=semver)](https://hub.docker.com/r/darthjee/node)
  - [![docker](https://img.shields.io/docker/v/darthjee/python_37.svg?logo=docker&label=python_37&sort=semver)](https://hub.docker.com/r/darthjee/python_37) (deprecated, use `python`)
  ...
```

#### Impact on scripts

- **`bin/script.sh init` needs no change:** it never touched the root README (which is why the hardcoded versions went stale). The badge shows the live Docker Hub version, so nothing has to be replaced on a new version.
- **`bin/archive.sh` must change:** `remove_from_readme` removes the archived image's root README line with `grep -v "^  - \[${image}:"`, which no longer matches a badge line — archiving would silently leave the badge behind. Change it to match on the Docker Hub link at the end of the line, e.g. `grep -v "(https://hub.docker.com/r/darthjee/${image})"`: the closing `)` keeps the match exact (`node` must not match `node_mongo` or `circleci_node`), and it is independent of the badge's label/style.
  - Update any tests covering `archive` and the docs describing it accordingly.

### Badge placement in image READMEs

The badge goes **right under the title**: after the `=` underline of `darthjee/<image>`, separated by blank lines, before `## About the image`. This mirrors the root README (title, then badges). The `docs/agents/image-readme.md` skeleton is updated accordingly:

````markdown
darthjee/<image>
================

<docker badge>

## About the image
...
````

Example:

```markdown
darthjee/ruby_331
=================

[![docker](https://img.shields.io/docker/v/darthjee/ruby_331.svg?logo=docker&label=ruby_331&sort=semver)](https://hub.docker.com/r/darthjee/ruby_331)

## About the image
```

### Edge cases

Verified live against shields.io for all 33 images in `version`:

- **`latest` tag:** not an issue — the badge resolves to the same version as the root `version` file for every image (with and without `sort=semver`); `latest` is never shown.
- **Underscores in labels:** `label=circleci_node_mongo` renders verbatim (the `_`-as-space rule only applies to static badge paths, not the query param).
- **Color:** shields' default — orange for `0.x` versions, blue for `>= 1.0`. Accepted as is; no color override.

Accepted, no action needed:

1. **`sort=semver` is kept** even though the default currently gives the same result: if an older version is ever re-pushed, date sorting would show it; semver always shows the highest version.
2. **`init`-ed but unreleased version:** the badge keeps showing the previous released version until the release job pushes the new one — the badge reflects Docker Hub, by design.
3. **Brand-new image not yet on Docker Hub:** shows a red "repository or tag not found" badge until its first release. Acceptable.
4. **Caching:** shields.io / GitHub's image proxy (camo) cache badges, so a new release may take some time to appear.
5. **Archived images:** their root README line is removed by `bin/archive.sh` (see [Root README layout](#root-readme-layout)); their image READMEs go away with their folders.

### Testing

- No automated tests are needed (none cover READMEs or `bin/archive.sh`); this is a README-only change for the images (no `bin/script.sh pre_build`/`build`/`test` needed).
- Check the root README rendering on GitHub (all 33 badges resolve to a version, none show "repository or tag not found").
- Manually check the new `remove_from_readme` match: it removes exactly the target line (e.g. `node`) and leaves `node_mongo` / `circleci_node` intact.
- After `push_description`, check the rendered descriptions on Docker Hub.

## Benefits

- The root README never shows stale versions again, with zero maintenance.
- Docker Hub visitors see the current version at a glance.
- Consistent badge convention across the repo, enforced for future images through `docs/agents/image-readme.md`.
