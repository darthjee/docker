# Issue: ruby_node 2.0.0: rebase onto ruby_3412, Node 24, bump packages

## Description

`ruby_node` (`1.6.0`, with `circleci_` and `production_` counterparts) is built on `ruby_331:1.2.0` and installs Node 22 via nodesource. As part of epic #256, release `2.0.0` of all three images rebased onto the new `ruby_3412:1.0.0` family (Ruby 3.4.12) with Node 24.

Depends on #257 (`scripts` 0.15.0) and #258 (`ruby_3412`) — both merged. All three bases are published on Docker Hub for `amd64` + `arm64`: `darthjee/ruby_3412:1.0.0`, `darthjee/circleci_ruby_3412:1.0.0`, `darthjee/production_ruby_3412:1.0.0`.

## Problem

- `ruby_node` 1.6.0 is still on Ruby 3.3.1 (`ruby_331`) and Node 22, which is now in maintenance.
- Its `home/Gemfile` is a stale copy of the `ruby_331` Gemfile left behind by #224: no `ruby_node` Dockerfile copies it and there is no bundle step, so it has no effect (gems come from the base image).
- The install `RUN` chains commands with `;`, so a failed `curl` or missing package is silently swallowed and the build still "succeeds".
- It runs `curl -L https://npmjs.org/install.sh | /bin/bash`, an unpinned second remote script that replaces the bundled npm with whatever is newest at build time — rebuilds are not reproducible.
- The apt lists are left in the layer.
- The subtests only check that `ruby`/`node` run, not which major is installed.

## Expected Behavior

- `darthjee/ruby_node:2.0.0`, `darthjee/circleci_ruby_node:2.0.0` and `darthjee/production_ruby_node:2.0.0` ship Ruby 3.4.12 (from `ruby_3412`) and Node 24 with its bundled npm, plus `ncat`.
- The images build on `linux/amd64` and `linux/arm64`, and the build fails loudly if any install step fails.
- The `latest` tag moves to `2.0.0` on release; `1.5.0`/`1.6.0` are untouched, and children pinned to `ruby_node:1.6.0` are unaffected.
- Subtests assert Node `v24.*` and Ruby `3.4.*`, and that `npm`/`ncat` are present.

## Solution

### 1. Create the version

`bin/script.sh init ruby_node 2.0.0` — creates `ruby_node/2.0.0`, `circleci_ruby_node/2.0.0`, `production_ruby_node/2.0.0` from `1.6.0` and updates `version`. Major bump: Ruby 3.3 → 3.4, Node 22 → 24.

### 2. Delete `home/`

Remove `home/` (the unused `Gemfile`) from all three `2.0.0` folders. The gem set is owned by `ruby_3412`, which `ruby_node` inherits. This matches `docs/agents/architecture.md`, which already describes `ruby_node` as having no `home/` folder (hence its own `test/Dockerfile`).

### 3. Dockerfiles

Each image rebases onto its own `ruby_3412` counterpart:

| Image | 1.6.0 base | 2.0.0 base | Final `USER` |
|---|---|---|---|
| `ruby_node` | `ruby_331:1.2.0` | `ruby_3412:1.0.0` | `app` |
| `circleci_ruby_node` | `circleci_ruby_331:1.2.0` | `circleci_ruby_3412:1.0.0` | `circleci` |
| `production_ruby_node` | `production_ruby_331:1.2.0` | `production_ruby_3412:1.0.0` | `app` |

`ruby_node/2.0.0/Dockerfile` (the others differ only in `FROM` and the final `USER`):

```dockerfile
FROM darthjee/ruby_3412:1.0.0

USER root

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs ncat && \
    rm -rf /var/lib/apt/lists/*

USER app
```

Changes vs `1.6.0`:

1. `;` → `&&` so a failed download or missing package fails the build.
2. `curl -fsSL` so an HTTP error aborts instead of piping an error page into `bash`.
3. No separate `apt-get update` — the nodesource setup script already runs it.
4. `--no-install-recommends` + `rm -rf /var/lib/apt/lists/*` to keep the layer small.
5. A single `RUN` adds one layer with only the delta (Node + ncat); nothing from `ruby_3412` is reinstalled.
6. **The `npm install.sh` step is dropped**: npm comes bundled with nodesource's `nodejs` (npm 11.x on Node 24), so its version is tied to the Node version. `rails_yarn` (the only maintained child) works with it.

Notes:

- **Node 24** (Krypton, Maintenance LTS, supported until April 2028) via **nodesource**. Node 26 (Active LTS since 2026-10-28) was deferred: very fresh, and `rails_yarn`'s frontend tooling may lag on native modules; 24 also aligns with `rails_yarn` (#261). Rejected: copying official binaries from `node:24-*-slim` (fiddly npm/corepack symlinks, Debian-release coupling) and Debian's own `nodejs` (too old).
- Bases: `ruby_3412`/`production_ruby_3412` are Debian **trixie**, `circleci_ruby_3412` (cimg) is Ubuntu **jammy**; nodesource 24.x supports both, and `curl` is present in all three.
- `ncat` is kept (used by `rails_yarn` and `scripts`' `check_specs`).
- The epic's `scripts:0.15.0` rule does not apply: `ruby_node` has no `scripts` build stage.
- Accepted risk: `--no-install-recommends` may omit packages a child needs (e.g. `python3` for node-gyp); the child adds them as its own delta.

### 4. READMEs

Update each `2.0.0/README.md` per `docs/agents/image-readme.md`: built on `darthjee/ruby_3412` (and counterparts), Ruby 3.4.12, Node 24 from NodeSource with its bundled npm, `ncat`.

### 5. Tests

In all three images' `2.0.0/test/subtests/`:

- `node.sh` — assert the Node major, then run the script:

  ```bash
  #!/bin/bash
  set -e
  node --version | grep -q '^v24\.' || { echo "expected Node 24, got $(node --version)"; exit 1; }
  node /home/test/test.js
  ```

- `bundler.sh` — assert Ruby 3.4:

  ```bash
  #!/bin/bash
  set -e
  ruby --version | grep -q '^ruby 3\.4\.' || { echo "expected Ruby 3.4, got $(ruby --version)"; exit 1; }
  gem --version && bundle --version
  ```

- `tools.sh` (new):

  ```bash
  #!/bin/bash
  set -e
  npm --version
  ncat --version
  ```

Verify with `bin/script.sh test <image>` on `linux/amd64` and `linux/arm64` (`PLATFORM=linux/arm64`) for all three images, plus `docker buildx build --platform linux/amd64,linux/arm64` without `--push` for each. No arch-specific logic is needed: apt resolves `nodejs` and `ncat` for both arches; release needs no change (`bin/image.sh push` already builds both).

### 6. Root wiring (architect)

- `.circleci/config.yml` `requires:` — `release-ruby_node`: `release-ruby_331` → `release-ruby_3412`; `release-circleci_ruby_node`: `release-circleci_ruby_331` → `release-circleci_ruby_3412`; `release-production_ruby_node`: `release-production_ruby_331` → `release-production_ruby_3412`.
- `.claude/agents/ruby-node.md`: "`ruby_node/` — `ruby_331` + Node" → "`ruby_3412` + Node".
- `docs/agents/architecture.md` hierarchy tree: add `ruby_3412` / `circleci_ruby_3412` / `production_ruby_3412` nodes and move the three `ruby_node` entries under them; keep `ruby_331` for images still built on it. The note that `ruby_node` has no `home/` becomes accurate again — no change.

### Out of scope

- Rebasing child images: `rails_yarn` (and `taa`/`taap` through it) has its own sub-issue (#261); `rails_bower` is **deprecated** and stays on `ruby_node:1.6.0`.
- Adding gems or npm packages to `ruby_node`.
- Touching `1.5.0` / `1.6.0`.
- Node 26 (a later, separate bump).

### Edge cases

- If nodesource ever drops a distro (e.g. jammy for `circleci_ruby_node`), the build now fails visibly thanks to `&&`; handled in a future version.
- Building `amd64` on an `arm64` host goes through QEMU — slow but functional.

Part of epic #256.

## Benefits

- Ruby 3.4.12 and a supported Node LTS (24, until April 2028) for `ruby_node` users, unblocking `rails_yarn` (#261).
- Reproducible, fail-fast builds: no unpinned npm script, no swallowed errors.
- Smaller layer, and no dead `Gemfile` drifting out of date.
- Tests that catch a wrong Node/Ruby major.
