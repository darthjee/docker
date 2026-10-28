# Issue: Remove the darthjee/heroku image

## Description

Remove the `darthjee/heroku` image from the repository. It is no longer used, so instead of writing a README for it (the original scope of this sub-issue under epic #153), the image is dropped entirely — the same approach #154 took for `darthjee/fly`.

With `fly` already removed (#154), `heroku` is the last image owned by the `tools` agent, so the `tools` agent is removed as well.

Parent epic: #153

## Problem

- `heroku/0.0.1` is unused, built on an EOL base (`alpine:3.13.5`) with an unpinned Heroku CLI, and still rebuilt and pushed by the `release-heroku` CircleCI job on every release tag.
- It has no README, so it blocks the README rollout of epic #153 for an image nobody needs.
- Once it is gone, the `tools` agent (`.claude/agents/tools.md`, `.claude/scripts/check_tools.sh`) owns nothing.

## Expected Behavior

- No `heroku/` folder, `heroku` entry in `version`, `release-heroku` CI job, or `heroku` mention in the root README image list.
- No `tools` agent definition or check script, and no reference to it in the other agents or docs.
- Every other image and release job is unaffected.

## Solution

### Scope

#### Image and release

- `git rm -r heroku/` (Dockerfile, `home/` scripts, and the `script/` host wrapper).
- Remove the `heroku=0.0.1` line from `version`.
- Remove the `release-heroku` job from `.circleci/config.yml`. The `&tag_only` anchor lives on `release-scripts`, so no anchor move is needed.
- Remove the `heroku:0.0.1` entry from the root `README.md` image list.

#### Documentation

- `AGENTS.md`: drop `heroku` from the *Tool images* example (leave `scripts`) and remove the `heroku/` line from the folder tree.
- `docs/agents/folder-structure.md`: remove the `heroku/` row.

#### `tools` agent

- Delete `.claude/agents/tools.md` and `.claude/scripts/check_tools.sh`.
- `.claude/agents/architect.md`: remove the `tools` row from the agent table.
- `.claude/agents/shell.md`: remove the "Do NOT touch `heroku/` (owned by the `tools` agent)" reference.
- `.claude/configuration/arcanum-repo-config.json` (this repo only): remove the `tools` key from `git.agents`. The `darthjee+infra@gmail.com` author itself stays (still mapped to `shell`), and no global arcanum/Claude configuration outside this repo (`~/.claude*`) is touched — other projects keep using that author.

#### Out of scope

- The "layer limit (40 for Heroku)" mentions in `README.md` and `docs/agents/architecture.md` refer to deploying production images to the Heroku platform, not to this image — keep them.
- The `darthjee/heroku` repository on Docker Hub is left as is (no deletion/archival from this repo). Its last pushed tags (on `alpine:3.13.5`) stay pullable but will no longer receive updates.
- Epic #153's body is not updated; `heroku` simply no longer needs a README.
- The git-ignored local state `.claude/state/arcanum-config.json` (which also lists a `tools` author) is not touched.

### Edge cases

- **Installed host wrapper (manual, outside the repo):** removing the source does not uninstall the `heroku install` wrapper on any machine where it was run. There, the wrapper keeps pulling `darthjee/heroku` from Docker Hub, and `~/.dt-heroku/config/.netrc` keeps a Heroku API token. Manual cleanup on such machines: delete `~/.dt-heroku`, remove the `eval "$($HOME/.dt-heroku/heroku install -)"` line from `~/.bashrc`, and revoke the Heroku token if still valid. (Not installed on the maintainer's current machine.)
- **CI / build scripts:** no other CircleCI job `requires: [release-heroku]` and nothing under `bin/` references `heroku`, so removing the job and the `version` line leaves nothing dangling.
- **Historical docs:** no other issue/plan file under `docs/agents/` mentions `heroku`, so there is nothing to rewrite there.

### Alternative solutions

Chosen: **remove the image outright**, consistent with the `fly` removal in #154. Alternatives considered and rejected:

- **Keep it and add the README** (the original scope) — would mean maintaining an unused image on an EOL base (`alpine:3.13.5`) with an unpinned Heroku CLI, which would soon need a rebuild just to stay current.
- **Deprecate first, then remove** — push a "deprecated" README to Docker Hub before deleting the source. Rejected as an unnecessary two-step process for an image the owner no longer uses; #154 did not do this for `fly` either.
- **Extract to a separate repository** — only worthwhile if the image were still needed.

### Counterpart images

None. There is no `circleci_heroku` or `production_heroku`, and no Dockerfile in the repo builds `FROM darthjee/heroku`, so removing it affects no other image.

### Dependencies

- None. #154 (fly removal) is already merged.
- Epic #153: once this lands, `heroku` no longer needs a README, so it drops out of the epic's image list.

### Responsible agent

`architect` (cross-cutting: CI config, root files, docs and agent definitions; the `tools` agent itself is being removed).

### Testing

No automated tests. Verify that:

- `grep -rni "heroku\|check_tools" .` (excluding `.git`, `docs/agents/issues` and `docs/agents/plans`) returns only the Heroku-platform layer-limit notes.
- No remaining reference to the `tools` agent in `.claude/` or `AGENTS.md`.
- `.circleci/config.yml` is valid YAML and the CircleCI pipeline passes on the PR.

## Benefits

- Smaller repo, release workflow and agent roster; one fewer image to keep current.
- Epic #153 no longer needs a README for an unused image.
