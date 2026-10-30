# Plan: Remove hardcoded version tags from existing READMEs

Issue: [173-remove-hardcoded-version-tags-from-existing-readmes.md](../../issues/173-remove-hardcoded-version-tags-from-existing-readmes.md)

## Overview

Apply the epic #153 README convention to the 13 older current-version READMEs: replace every hardcoded `darthjee/<image>:<tag>` (31 occurrences in `FROM`, CircleCI `- image:` and `docker pull` lines) with `darthjee/<image>:<version>`, and add the Docker Hub tags-list pointer to each *How to use* intro. Documentation-only, in place: no `init`, no new version, no rebuild.

## Agents involved

- [ruby](ruby.md) — `ruby_331`, `circleci_ruby_331`, `production_ruby_331`, `rails_gems`, `circleci_rails_gems`
- [ruby-node](ruby-node.md) — `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn`, `ruby_node`, `circleci_ruby_node`, `production_ruby_node`, `taa`, `circleci_taa`, `production_taa`

## Shared contracts

Both agents apply the same convention, as already used by `node/0.2.2/README.md` and `circleci_node/0.2.2/README.md`:

- **Tag placeholder**: every `darthjee/<image>:<digits...>` becomes `darthjee/<image>:<version>` — the literal string `<version>`. Applies to `FROM`, `- image:` and `docker pull` lines alike (no `:latest`).
- **Tags pointer**: the first sentence under `## How to use` (the one ending in `` `Dockerfile`: `` or `` `.circleci/config.yml` or `Dockerfile`: ``) gets ` (see the available tags at https://hub.docker.com/r/darthjee/<image>/tags)` inserted right before its final colon, where `<image>` is that README's own image. Example:

  ```markdown
  Reference this image in your `Dockerfile` (see the available tags at https://hub.docker.com/r/darthjee/rails_yarn/tags):
  ```

- Nothing else changes: pinned gem/package versions in the READMEs (e.g. `rails` (7.2.2.1)) stay, and so do older version folders, `bin/init.sh` and the root `README.md`.
- Only the current version folder from the root `version` file is edited.

### Verification (both agents)

This command must print nothing once both agents are done:

```bash
while IFS== read -r i v; do case "$i" in ""|\#*) continue;; esac; f="$i/$v/README.md"; [ -f "$f" ] && grep -nE "darthjee/[a-z0-9_]+:[0-9]" "$f" | sed "s|^|$f:|"; done < version
```

And each of the 13 READMEs must contain `https://hub.docker.com/r/darthjee/<image>/tags` for its own image.
