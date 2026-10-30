# Image READMEs

Conventions for the per-image `README.md` files published to Docker Hub as each repository's description.

## Purpose

`<image>/<version>/README.md` is the Docker Hub full description of `darthjee/<image>`. It is pushed automatically by the CI `release` job (`bin/image.sh description <image>`, only when `<image>/<version>/` changed since the previous tag) and by hand with `bin/script.sh push_description <image>` (see `bin/push_description.sh`). Both always read the README of the version listed in the root `version` file.

These rules apply to every new README and to any README being edited. Existing READMEs are not rewritten just to follow them: known deviations (e.g. hardcoded `darthjee/<image>:<version>` tags, an unlinked "counterpart of" mention, a parent image's version) are fixed by a dedicated cleanup issue or the next time that README is edited for another reason.

## Skeleton

Every image README follows this skeleton:

````markdown
darthjee/<image>
================

## About the image
<what it is, base image (linked if darthjee/), counterpart intro, legacy note if EOL>
<default user/uid, working directory and owner>

## <middle section(s) — see the menu>

## How to use
<tags link + Dockerfile or CircleCI YAML example with <version>>

## License

See the LICENSE file for more information.
````

- The title is `darthjee/<image>`, underlined with `=` to the title's length.
- `## About the image`, zero or more middle sections, `## How to use` and `## License`, in that order.
- The license line is plain text (see [Docker Hub rendering](#docker-hub-rendering)).

## About the image

State, in prose:

- What the image is and what it is meant for.
- The base image it is built on. Link it when it is a `darthjee/` image (`https://hub.docker.com/r/darthjee/<parent>`), but never mention its tag (see [Versions and architectures](#versions-and-architectures)).
- What the base image already provides, when relevant (e.g. git and the usual CircleCI tooling).
- The default user (and uid when known), the working directory and its owner.
- For `circleci_`/`production_` images, the counterpart intro (see [Counterparts and families](#counterparts-and-families)).
- For images on an end-of-life base, a legacy note:

  ```markdown
  > **Note:** This is a legacy image built on an old, end-of-life base (`<base>`).
  ```

  Drop the note when the image is rebuilt on a supported base.

**Source of facts:** derive every statement from the image's Dockerfile, its `home/` files and the build-time scripts it runs (e.g. `poetry_builder.sh` from `darthjee/scripts`) — never from memory or from another image's README.

## Middle sections

Pick the sections that fit the image; none is mandatory.

| Section | When to use it | Reference |
|---------|----------------|-----------|
| `## Tools` | Tools installed globally (e.g. `pipenv`, `poetry`). | [`python`](../../python/0.1.0/README.md) |
| `## Pre-installed packages` / `## Pre-installed gems` | Packages actually installed in the image. Group them with `###` subheadings when the list is long. | [`rails_gems`](../../rails_gems/2.1.1/README.md) |
| `## Pre-cached packages` | A pre-populated package-manager cache rather than installed packages. Say where the cache lives and that packages are only used when a project asks for them. | [`node`](../../node/0.2.2/README.md) |
| `## What is added` | Images built on a `darthjee/` parent: list only what this image adds on top of the parent. | [`ruby_node`](../../ruby_node/1.5.0/README.md) |
| `## Included scripts` | Scripts copied from `darthjee/scripts`. | [`ruby_331`](../../ruby_331/1.1.1/README.md) |
| `## Usage example` | Tool images (e.g. `scripts`) that are consumed with `COPY --from=` rather than `FROM`. | [`scripts`](../../scripts/0.10.0/README.md) |
| `## Variants` | Optional table of the image family (dev / CircleCI / production). Allowed in dev READMEs, never required. | [`ruby_node`](../../ruby_node/1.5.0/README.md) |

List tools and packages by name only.

## How to use

- Link the available tags: `https://hub.docker.com/r/darthjee/<image>/tags`.
- Use `<version>` as the tag placeholder in every example.
- Dev and production images: a `Dockerfile` example starting with `FROM darthjee/<image>:<version>`.
- `circleci_` images: a CircleCI executor example in `.circleci/config.yml` (`docker: - image: darthjee/<image>:<version>`); a `Dockerfile` example may follow.
- Tool images (`scripts`): `COPY --from=darthjee/scripts:<version> …` rather than `FROM`.
- Production images: install main dependencies only (e.g. `poetry install --only main`, `bundle install --without development test`).
- Add short edge-case sentences where relevant, e.g. where the virtualenv lives and that commands run through `poetry run`/`pipenv run`, or when a pre-populated cache is bypassed.

## Versions and architectures

- **No `darthjee/` tags**, neither the image's own nor its parent's. `bin/script.sh init` copies the README to the new version folder unchanged and only bumps the Dockerfile's `FROM` lines (`update_dependencies`), so any tag in the README silently goes stale. The Dockerfile is the source of truth; the README links the tags page instead.
- **No tool or package versions**: list them by name only.
- **Exception:** versions that are part of an upstream base's identity and only change with a rebuild may be stated (e.g. Python 3.12 from `python:3.12-slim-bookworm`, `circleci/python:3.7.2`).
- **No architecture claims** (e.g. "multi-arch", `linux/arm64`).

## Counterparts and families

1. **Intro:** `circleci_`/`production_` READMEs open with "the CircleCI counterpart of" / "the production counterpart of [`darthjee/<dev>`](https://hub.docker.com/r/darthjee/<dev>)" and state whether they are built on top of the dev image or are counterparts by name only (parallel, e.g. built on `cimg/` or on a legacy `circleci/` base). Production intros add "without development dependencies".
2. **One-way links:** counterparts link to the dev image; dev READMEs do not link to their counterparts, except through the optional `Variants` table.
3. **Mirrored hierarchies link both:** e.g. `circleci_ruby_node` links its parent `circleci_ruby_331` (no version) and its dev counterpart `ruby_node`.
4. **Order and reuse:** write the dev README first. Counterparts reuse its structure and wording, changing only what differs — user and working directory (e.g. `circleci` and `/home/circleci/project`), the usage example (CircleCI YAML, production-only install) and dropped dev tools. Production package/cache lists exclude dev tools.
5. **Family sync:** a change to content shared across the family (e.g. the `pyproject.toml`/`Gemfile` copied by `update_deps`) updates the counterparts' READMEs in the same PR.
6. **Family push:** `bin/script.sh push_description <dev>` pushes the dev image and its `circleci_`/`production_` counterparts (skipping counterparts whose folder does not exist) and skips any image whose README is missing with a warning.

CircleCI images on a legacy base (e.g. `circleci/python:3.7.2`, `circleci/node:10.7`) are counterparts by name only and carry the legacy note; see [`circleci_python_37`](../../circleci_python_37/0.2.2/README.md).

## Docker Hub rendering

- Use absolute `https://` links and image URLs only. Relative links (e.g. `../../LICENSE`) break on Docker Hub, hence the plain-text license line.
- `full_description` is limited to 25,000 characters; current READMEs are far below that.

## Process

> **README follows the image:** any change to an image's contents (e.g. a new version via `bin/script.sh init` that adds or removes packages or tools) updates that image's `README.md` in the new version folder in the same PR — and, for content shared across the family, its counterparts' READMEs too. `init` copies the README unchanged, so otherwise it silently goes stale.

- **README-only changes** are made in place: no `bin/script.sh init`, no `version` bump.
- Always edit the README in the folder the `version` file points to (the one `bin/push_description.sh` reads), including a not-yet-released folder created by `init`.
- Never edit older version folders, even if their README is wrong or missing — nothing reads them.
- Fixing the README of an already-released version in place is fine: the Docker Hub description is per repository, not per tag, so the next `push_description` publishes it without retagging. This is the README exception to [Fix vs. New Version](contributing.md#fix-vs-new-version).
- A README-only change needs no `bin/script.sh pre_build`/`build`/`test` run, since the image is unchanged — an explicit exception to [CI Checks](contributing.md#ci-checks).
- The CI `release` job pushes the description after the image push (`bin/image.sh description <image>`), only when `<image>/<version>/` changed since the previous tag. A README-only change updates the description without re-pushing the image. For a README unchanged since the latest tag, run `bin/script.sh push_description <image>` by hand.
- **Testing:** READMEs have no automated tests. Check the rendered description on Docker Hub after the next `push_description`.

## Reference examples

Full examples of the rules above (each in the folder `version` points to):

| README | Shows |
|--------|-------|
| [`python`](../../python/0.1.0/README.md) | Minimal README: `Tools`, virtualenv sentence. |
| [`circleci_python`](../../circleci_python/0.1.0/README.md) | CircleCI counterpart by name only, on a `cimg/` base. |
| [`circleci_python_37`](../../circleci_python_37/0.2.2/README.md) | Deprecated CircleCI counterpart by name only, on a legacy base. |
| [`node`](../../node/0.2.2/README.md) | `Pre-cached packages`. |
| [`rails_gems`](../../rails_gems/2.1.1/README.md) | `Pre-installed gems` grouped with `###`. |
| [`ruby_node`](../../ruby_node/1.5.0/README.md) | `What is added` and `Variants`. |
| [`scripts`](../../scripts/0.10.0/README.md) | Tool image with `Usage example`. |

Some of these predate this spec and still carry known deviations (e.g. hardcoded tags); follow the rules above, not those deviations.
