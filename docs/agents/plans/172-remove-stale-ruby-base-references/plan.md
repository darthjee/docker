# Plan: Remove stale ruby_base references

Issue: [172-remove-stale-ruby-base-references.md](../../issues/172-remove-stale-ruby-base-references.md)

## Overview
Remove the three leftover references to the nonexistent `ruby_base` image: its `version` entry, its README listing and its CI release job. These are root-level and CI files, so `architect` owns the change. No specialist agent has work.

## Context
The `ruby_base/` folder does not exist and never has. `release-ruby_base` passes only because `skip_if_unchanged` (`bin/image.sh`) sees no diff and skips the build. The repo references `ruby_base` in exactly three places:

- `version:11`: `ruby_base=0.2.2`
- `README.md:107`: `- [ruby_base:0.2.2](https://hub.docker.com/repository/docker/darthjee/ruby_base)`
- `.circleci/config.yml:41-44`: the `release-ruby_base` job. No other job lists it in `requires:`.

## Implementation Steps

### Step 1 — Remove the version and README entries
Delete the `ruby_base=0.2.2` line from `version` and the `ruby_base:0.2.2` bullet from the root `README.md`'s Development image list. Leave the surrounding entries and their order as they are.

### Step 2 — Remove the CI release job
Delete the whole `- release:` block named `release-ruby_base` (4 lines) from `.circleci/config.yml`, under `# ── Development ──`. Do not touch any `requires:` list, because none of them reference it. Then run `grep -rn ruby_base --exclude-dir=.git .` and confirm the only matches left are under `docs/agents/issues` and `docs/agents/plans`.

## Files to Change
- `version`: remove the `ruby_base=0.2.2` line.
- `README.md`: remove the `ruby_base:0.2.2` list bullet.
- `.circleci/config.yml`: remove the `release-ruby_base` job.

## CI Checks
- `.circleci/config.yml`: run `circleci config validate`, if the CLI is installed. Otherwise parse the YAML, e.g. `ruby -ryaml -e 'YAML.load_file(".circleci/config.yml")'`.

## Notes
- No image is built or tested, so there is no need to run `docker buildx` or the image test suites.
- Out of scope: the `darthjee/ruby_base` repository on Docker Hub.
