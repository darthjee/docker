# Issue: Document the image README conventions for Docker Hub descriptions

## Description

Document the conventions for per-image `README.md` files (published to Docker Hub as the repository description by `bin/push_description.sh`) in a new `docs/agents/image-readme.md`, so future README issues (the remaining sub-issues of Epic #153 and any later image change) point to a spec instead of re-deciding the same questions. The conventions were settled one by one while working on #156–#162.

## Problem

Each README sub-issue so far (#156–#162) re-discussed the same topics — structure, version tags, multi-arch claims, legacy notes, counterpart wording, fix vs. new version, testing — because the decisions only live in individual issue bodies and merged READMEs. Epic #153 and its open sub-issues still say to follow `circleci_rails_gems/2.1.1/README.md`, which no longer matches the agreed shape. `AGENTS.md` also has stale statements: it calls the README "optional" and says no `bin/` script publishes descriptions, although `bin/push_description.sh` does. Nothing tells agents that a README must change when its image changes.

## Expected Behavior

- `docs/agents/image-readme.md` exists and documents every rule in the Solution below, including the embedded skeleton.
- `AGENTS.md` links to it from the version-folder list, the "Docker Hub Description Publishing" section and the documentation table, and no longer has the two stale statements.
- `.claude/agents/architect.md` lists it in its documentation table; each specialist (`node`, `python`, `ruby`, `ruby-node`, `shell`) points to it from `## Conventions`.
- `docs/agents/issue-enhancement.md` points README issues to it.
- `.claude/agents/python.md` no longer says `circleci_python_37` is based on `cimg`.
- No image README, Dockerfile or `version` entry changes.

## Solution

### Spec: general rules

- **Structure:** the shared skeleton and middle-section menu described in *Existing READMEs* and *Alternative solutions* below.
- **Source of facts:** derive content from the Dockerfile, `home/` files and build-time scripts (e.g. `poetry_builder.sh` from `darthjee/scripts`). State the default user/uid, the working directory and its owner, and what the base image provides.
- **No version numbers** (refined under *Existing READMEs*): use `FROM darthjee/<image>:<version>` and link to `https://hub.docker.com/r/darthjee/<image>/tags`; list tools/packages by name only (except what the base tag implies, e.g. Python 3.12), since `bin/script.sh init` copies the README forward unchanged.
- **No architecture claims.**
- **Legacy note** for images on end-of-life bases, e.g. `> **Note:** This is a legacy image built on an old, end-of-life base (...).` — to be dropped when the image is rebuilt.
- **Counterparts:** `circleci_`/`production_` READMEs open with a "counterpart of [`darthjee/<dev>`](https://hub.docker.com/r/darthjee/<dev>)" intro, linking back, and say whether they are built on top of the dev image or are counterparts by name only. Dev READMEs do not link to their counterparts.
- **Usage examples:** a Dockerfile example for dev/production images; a CircleCI executor YAML example for `circleci_` images. Add short edge-case sentences where relevant (where the virtualenv lives and `poetry run`/`pipenv run`; when a pre-populated cache is bypassed).
- **Process:** see *Process* below.
- **Testing of READMEs:** no automated tests; a manual Docker Hub check after the next release (or a manual `push_description`).

### Spec: structure and existing READMEs

All 21 existing READMEs already share one skeleton, so the spec describes that skeleton rather than a single model file, and **no existing README is rewritten** by this issue.

- **Skeleton:** `darthjee/<image>` title underlined with `=`, `## About the image`, zero or more middle sections, `## How to use`, `## License`.
- **Middle sections (pick what fits the image):**
  - `Tools` — globally installed tools (e.g. `python_37`).
  - `Pre-installed packages` / `Pre-installed gems` — packages installed in the image, grouped with `###` subheadings when long (e.g. `rails_gems`, `node_mongo`).
  - `Pre-cached packages` — a pre-populated package-manager cache rather than installed packages (e.g. `node`, `django`).
  - `What is added` — for images built on a `darthjee/` parent, only what this image adds (e.g. `ruby_node`, `taa`).
  - `Included scripts` — scripts copied from `darthjee/scripts` (e.g. `ruby_331`).
  - `Variants` — optional family table (e.g. `ruby_node`, `taa`); allowed in dev READMEs but not required.
- **Reference examples** replace "follow `circleci_rails_gems`": `python_37` (minimal), `node` (pre-cached), `rails_gems` (grouped gems), `ruby_node` (what is added + variants).
- **No versions, including the parent's:** name the parent image (linked), never its tag — the Dockerfile's `FROM` is the source of truth and `init` (`update_dependencies`) bumps it without touching the README. Exception: versions that are part of an upstream base's identity (e.g. Python 3.12 from `python:3.12-slim-bookworm`, `circleci/python:3.7.2`), which only change with a rebuild.
- **Known deviations in existing READMEs** are not fixed here: hardcoded `darthjee/<image>:<version>` tags (e.g. `circleci_rails_gems`, `circleci_ruby_node`, `circleci_rails_yarn`) are covered by the epic's tag-cleanup sub-issue; other gaps (unlinked "counterpart of" in Ruby READMEs, the parent version `0.0.7` in `circleci_node_mongo`) are fixed only when that README is next edited for another reason.
- The rules apply to new READMEs and to any README being edited.

### Spec: skeleton (chosen approach)

- **Chosen — prose spec with an embedded skeleton:** `docs/agents/image-readme.md` holds the rules and a fenced skeleton block, plus links to the reference READMEs for full examples:

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
- **Rejected — separate template file:** the middle sections vary too much per image, and a second file can drift from the spec.
- **Rejected — generator script:** the valuable content needs judgment, and a new `bin/` tool is overkill for the remaining READMEs.
- **Rejected — README lint check:** not pursued (neither here nor as a follow-up).

### Spec: edge cases

1. **Tool images (`scripts`):** no counterparts, so no counterpart intro; the middle-section menu allows `Usage example`; *How to use* shows `COPY --from=darthjee/scripts:<version> …` rather than `FROM`. `scripts` is the reference example (`fly`/`heroku` were removed in #154/#155).
2. **Production images:** intro "production counterpart of [`darthjee/<dev>`](…), without development dependencies"; package/cache lists exclude dev tools; the *How to use* example installs main dependencies only (e.g. `poetry install --only main`, `bundle install --without development test`).
3. **Highlighted rule — README follows the image:** any change to an image's contents (e.g. a new version via `init` that adds/removes packages or tools) updates that image's `README.md` in the new version folder in the same PR. `init` copies the README unchanged, so otherwise it silently goes stale.
4. **Docker Hub rendering:** only absolute `https://` links and images (relative links such as `../../LICENSE` break on Docker Hub, hence the plain-text license line); `full_description` is limited to 25,000 characters (the longest README today, `circleci_taa`, is ~125 lines — far below).
5. **CircleCI images on a legacy base** (`circleci/python:3.7.2`, `circleci/node:10.7`) vs. `cimg`: covered by the "counterpart by name only" wording plus the legacy note; `circleci_python_37` is the reference example.
6. **Images built on a `darthjee/` parent:** use `What is added` for the delta only; link the parent, never its version (see above).

### Spec: process (fix vs. new version)

- **This issue:** docs/agent files only — no image, `version`, or `init` change.
- **For the spec's process section**, in addition to "README-only change → in place, no `init`/version bump/build" and edge case #3:
  1. Always edit the README in the folder `version` points to (the one `bin/push_description.sh` reads), including a not-yet-released folder created by `init`.
  2. Never edit older version folders, even if their README is wrong or missing — nothing reads them.
  3. Fixing a README of an already-released version in place is fine: the Docker Hub description is per repository, not per tag, so the next `push_description` (or the release job once #171 lands) publishes it without retagging.

### Spec: counterpart rules

1. **Intro:** `circleci_`/`production_` READMEs open with "the CircleCI/production counterpart of [`darthjee/<dev>`](https://hub.docker.com/r/darthjee/<dev>)" and state whether they are built on top of the dev image or a counterpart by name only (parallel, e.g. on `cimg` or a legacy `circleci/` base).
2. **One-way links:** counterparts link to the dev image; dev READMEs do not link to their counterparts, except via the optional `Variants` table.
3. **Mirrored hierarchies link both:** e.g. `circleci_ruby_node` links its parent `circleci_ruby_331` (no version) and its dev counterpart `ruby_node`.
4. **Order and reuse:** the dev README comes first; counterparts reuse its structure and wording, changing only what differs (user/workdir such as `circleci` + `/home/circleci/project`, the usage example — CircleCI YAML or production-only install — and dropped dev tools).
5. **Family sync:** a change to content shared across the family (e.g. the `pyproject.toml`/`Gemfile` copied by `update_deps`) updates the counterparts' READMEs in the same PR (extends edge case #3).
6. **Family push behavior:** `bin/script.sh push_description <dev>` pushes the whole family and exits 1 on the first missing README (until #171 changes this), so run it only for complete families.

### `AGENTS.md` changes

1. Version-folder list (line ~98), replace the "(optional)" bullet with:
   > - `README.md` – Documentation for the image version, published to Docker Hub as the repository's full description. Every current image version should have one, written following [Image READMEs](docs/agents/image-readme.md).
2. "Docker Hub Description Publishing" section, replace the opening "may include" paragraph with:
   > Each image version should include a `README.md` (`<image>/<version>/README.md`, see [Image READMEs](docs/agents/image-readme.md)). It is published to Docker Hub as the repository's full description with `bin/script.sh push_description <image>`.
   >
   > `bin/push_description.sh` pushes the README of the version listed in `version` for `<image>` and its `circleci_`/`production_` counterparts (skipping counterparts whose folder does not exist). It authenticates via `docker_login` unless `DOCKER_HUB_TOKEN` is set, and fails with `Error: README not found at ...` if any of them has no README.
   >
   > The lower-level `docker_hub.sh` script, provided by the `scripts` image, offers the same operations:

   Keep the existing `docker_hub.sh` table and example unchanged.
3. Replace the closing note (line ~119) with:
   > **Note:** Releases (`bin/image.sh push`, the CI `release` job) do not push descriptions; run `bin/script.sh push_description` separately.

   No "yet" and no link to #171, so `AGENTS.md` carries no issue reference that goes stale.
4. Add the new doc's row to the `docs/agents/` documentation table:
   > | [Image READMEs](docs/agents/image-readme.md) | Conventions for per-image `README.md` files published as Docker Hub descriptions. |

### Agent files and `issue-enhancement.md`

- Add one bullet to the `## Conventions` section of each specialist (`.claude/agents/node.md`, `python.md`, `ruby.md`, `ruby-node.md`, `shell.md`):
  > - Each image version's `README.md` is the image's Docker Hub description; write and edit it following [docs/agents/image-readme.md](../../docs/agents/image-readme.md).
- Process details (in place, no `init`, no `version` bump) live only in the spec, not duplicated in agent files.
- `.claude/agents/architect.md`: add the new doc's row to its `docs/agents/` documentation table (same row as in `AGENTS.md`).
- Fix `.claude/agents/python.md:15`: only `circleci_django` is based on `cimg` (`cimg/python:3.12`); `circleci_python_37` is built on the legacy `circleci/python:3.7.2`.
- The spec states that a README-only change needs no `bin/script.sh pre_build`/`build`/`test` run (the image is unchanged), as an explicit exception to the CI-checks rule in `docs/agents/contributing.md`.
- `docs/agents/issue-enhancement.md`: add a line that issues adding or editing an image README follow `docs/agents/image-readme.md`.

### Post-merge follow-up (not part of the PR)

- This issue's implementation (the PR) changes **repo files only**: the spec, `AGENTS.md`, `docs/agents/issue-enhancement.md`. It does not edit any GitHub issue.
- **Post-merge follow-up (manual, by the architect, after this PR merges):**
  - Epic #153: replace the three "structure of `circleci_rails_gems/2.1.1/README.md`" mentions (goal, sub-issue breakdown, rationale) with a pointer to `docs/agents/image-readme.md`.
  - Open README sub-issues #163–#170: replace the "Follow the structure of `circleci_rails_gems/2.1.1/README.md`: …" bullet with "Follow `docs/agents/image-readme.md`."
  - #173: add the parent-version reference in `circleci_node_mongo/0.0.6/README.md` ("`circleci_node` `0.0.7`") and any other README naming a parent tag to its scope.
- Done after merge so the pointers never reference a missing file; each of #163–#170 still goes through `enhance-issue`, which acts as a safety net.
  - Comment on #171 that, when the release job starts pushing descriptions, it must update the `AGENTS.md` note and the spec's process section.

### Out of scope

- Writing or changing any image README (existing deviations are handled by #173 or when a README is next edited).
- Any lint check, template file, or generator script.
- Editing GitHub issues as part of the PR.

### Order

Ideally done before #163, so the remaining README sub-issues can reference the spec.

### Responsible agent

`architect` (owns `docs/agents/`, `AGENTS.md` and `.claude/agents/`).

### Testing

No automated tests (documentation only). Reviewed manually: links resolve, and the spec's rules match the merged READMEs of #156–#162.
