# Issue: Remove hardcoded version tags from existing READMEs

## Description

Several current-version READMEs hardcode `darthjee/<image>:<version>` tags (e.g. `circleci_rails_gems/2.1.1/README.md` shows `FROM darthjee/circleci_rails_gems:2.1.0` while the folder is `2.1.1`). `bin/script.sh init` copies the version folder with `cp -R` but only rewrites versions in `version` and Dockerfile `FROM` lines, so these tags go stale on every new version.

The epic (#153) convention is that READMEs do **not** hardcode image tags. The READMEs added under the epic (e.g. `node/0.2.2/README.md`, `circleci_node/0.2.2/README.md`) already follow it: usage examples use a `<version>` placeholder and the *How to use* intro points to the Docker Hub tags list. Apply the same convention to the older READMEs so the rule is uniform and `bin/init.sh` needs no change.

## Problem

13 current-version READMEs (31 occurrences) still hardcode a tag, all already stale (they point to the previous version):

- `ruby_331`, `circleci_ruby_331`, `production_ruby_331` (1.1.1) — `FROM ...:1.1.0`
- `rails_gems`, `circleci_rails_gems` (2.1.1) — `FROM ...:2.1.0`
- `rails_yarn`, `circleci_rails_yarn`, `production_rails_yarn` (1.1.0) — `FROM`, `image:` and `docker pull` with `:1.0.1`
- `ruby_node`, `circleci_ruby_node`, `production_ruby_node` (1.5.0) — `FROM`, `image:` and `docker pull` with `:1.4.2`
- `taa`, `circleci_taa`, `production_taa` (1.5.0) — `FROM`, `image:` and `docker pull` with `:1.4.2`

None of them link to the Docker Hub tags list.

## Expected Behavior

- Every `darthjee/<image>:<tag>` reference in these 13 READMEs (`FROM`, CircleCI `- image:` and `docker pull` lines) uses the `<version>` placeholder: `darthjee/<image>:<version>`.
- Each of these READMEs points readers to the available tags, matching the newer READMEs: the *How to use* intro gets `(see the available tags at https://hub.docker.com/r/darthjee/<image>/tags)`, with `<image>` being that README's own image.
- The rest of the text is unchanged. Pinned package/gem versions listed in the READMEs (e.g. `rails` (7.2.2.1)) are facts about the image contents and stay as they are.

## Solution

Edit the 13 READMEs in place, in each image's current version folder (from `version`); no `init`, no new version, no rebuild (README.md is not copied into the image).

Find them with:

```bash
while IFS== read -r i v; do case "$i" in ""|\#*) continue;; esac; f="$i/$v/README.md"; [ -f "$f" ] && grep -nE "darthjee/[a-z0-9_]+:[0-9]" "$f" | sed "s|^|$f:|"; done < version
```

### Out of scope

- Changing `bin/init.sh`.
- Older (non-current) version folders.
- The stale image/version list in the root `README.md` (e.g. `scripts:0.5.3` while `version` has `0.11.0`).
- Pinned package/gem versions inside the READMEs.

### Responsible agent

`architect` (cross-family documentation; may delegate per family to `ruby` for `ruby_331`/`rails_gems` and `ruby-node` for `rails_yarn`/`ruby_node`/`taa`).

### Testing

No automated tests. Re-run the command above: it must print nothing. Also check that every one of the 13 READMEs contains `https://hub.docker.com/r/darthjee/<image>/tags`.

Parent epic: #153
