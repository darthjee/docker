# Issue: Remove stale ruby_base references

## Description

`ruby_base` is still referenced in the repo, but there is no `ruby_base/` image folder, and git history shows there never was one:

- `version`: `ruby_base=0.2.2`
- root `README.md`: the Development image list includes `ruby_base:0.2.2` with a Docker Hub link
- `.circleci/config.yml`: a `release-ruby_base` job (`image: ruby_base`, tag-only). No other job `requires` it.

## Problem

The `release-ruby_base` job passes only because `skip_if_unchanged` (`bin/image.sh`) finds no diff under the missing `ruby_base/0.2.2/` path and skips the build. If that ever stopped happening, `docker buildx build` would fail because there is no Dockerfile. The README and `version` entries also advertise an image this repo does not build.

## Expected Behavior

`grep -rn ruby_base` finds nothing in the repo outside the issue and plan docs, and the release workflow no longer has a `release-ruby_base` job.

## Solution

- Remove the `ruby_base=0.2.2` line from `version`.
- Remove the `ruby_base:0.2.2` bullet from the root `README.md`.
- Remove the `release-ruby_base` job from `.circleci/config.yml`. No `requires:` lists reference it, so nothing else needs changing.
- Re-run `grep -rn ruby_base` to confirm nothing is left.

### Out of scope

- Deleting or changing the `darthjee/ruby_base` repository on Docker Hub.

### Responsible agent

`architect` (root-level files and `.circleci/config.yml`).

### Testing

There are no automated tests. Check that `.circleci/config.yml` is still valid (`circleci config validate`, if available) and that the next release workflow runs without the `release-ruby_base` job.

Parent epic: #153

## Benefits

Removes a dead CI job that could break the release workflow, and stops the README and `version` from advertising an image this repo does not build.
