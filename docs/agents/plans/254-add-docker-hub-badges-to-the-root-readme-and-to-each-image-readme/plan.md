# Plan: Add Docker Hub badges to the root README and to each image README

Issue: [254-add-docker-hub-badges-to-the-root-readme-and-to-each-image-readme.md](../../issues/254-add-docker-hub-badges-to-the-root-readme-and-to-each-image-readme.md)

## Overview

Add a shields.io Docker Hub version badge for each of the 32 images in the root `version` file: in the root `README.md` `## Images` list (replacing the stale hardcoded `[<image>:<version>](…)` links) and right under the title of each image's current `<image>/<version>/README.md`. The `docs/agents/image-readme.md` skeleton is updated to require the badge, and `bin/archive.sh`'s `remove_from_readme` is changed to match badge lines. This is a README-only change for every image: no `bin/script.sh init`, no `version` bump, no image build.

## Agents involved

- [architect](architect.md): root `README.md`, `docs/agents/image-readme.md`, `bin/archive.sh`.
- [node](node.md): `node`, `node_mongo`, `circleci_node`, `circleci_node_mongo` READMEs.
- [python](python.md): `python`, `python_37`, `django`, `circleci_python`, `circleci_python_37`, `circleci_django`, `production_django` READMEs.
- [ruby](ruby.md): `ruby_331`, `rails_gems`, `circleci_ruby_331`, `circleci_rails_gems`, `production_ruby_331` READMEs.
- [ruby-node](ruby-node.md): `ruby_node`, `rails_bower`, `rails_yarn`, `taa`, `taap` and their `circleci_`/`production_` counterparts (15 READMEs).
- [shell](shell.md): `scripts` README.

All agents' work is independent and can run in parallel.

## Shared contracts

**Badge**: the exact same markdown in the root README and in the image README, with `<image>` the image name as it appears in `version` (e.g. `circleci_ruby_331`):

```markdown
[![docker](https://img.shields.io/docker/v/darthjee/<image>.svg?logo=docker&label=<image>&sort=semver)](https://hub.docker.com/r/darthjee/<image>)
```

- The link target is the public page `https://hub.docker.com/r/darthjee/<image>`, exactly, with no trailing slash or path. `bin/archive.sh` relies on the substring `(https://hub.docker.com/r/darthjee/<image>)` to find the root README line.
- Version badge only: no pulls or size badges, no color override.

**Placement in image READMEs**: right after the `=` underline of the `darthjee/<image>` title, with a blank line before and after it, before `## About the image`:

```markdown
darthjee/<image>
================

[![docker](https://img.shields.io/docker/v/darthjee/<image>.svg?logo=docker&label=<image>&sort=semver)](https://hub.docker.com/r/darthjee/<image>)

## About the image
```

**Which README**: only `<image>/<version>/README.md` where `<version>` is the image's line in the root `version` file. Never edit older version folders. Change nothing else in the README.

## Notes

- After merge, the repo owner pushes the descriptions to Docker Hub by hand. The PR description must list the commands: `bin/script.sh push_description <dev image>` for each dev image (it also pushes the `circleci_`/`production_` counterparts), plus `bin/script.sh push_description scripts`. No agent runs them.
- No `bin/script.sh pre_build`/`build`/`test` run is needed: README-only change (see [Image READMEs → Process](../../image-readme.md#process)).
