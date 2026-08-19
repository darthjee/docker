# Issue: Modernize multi-arch image builds to docker buildx instead of QEMU + per-arch docker build

## Description

This repo's `bin/image.sh` (and majora's copy of the same pattern) currently builds multi-arch images by
registering QEMU user-mode emulation (`docker run --privileged --rm tonistiigi/binfmt --install all`) and then
running a separate `docker build --platform linux/$arch ...` invocation per architecture, producing separate
`:<version>` / `:<version>-arm64` tags rather than a single multi-platform manifest.

This came up while porting the same release mechanism to a third project, `oak` (darthjee/oak#217) — oak
deliberately kept the QEMU + per-arch-build pattern for consistency with this repo and majora, rather than
adopting something more modern on its own. This issue is the follow-up to evaluate that modernization at the
source (this repo), since both majora and oak inherit their base images and build patterns from here — a
change made here can propagate outward.

## Problem

- Two full CI jobs per image (`release-<image>` and `release-<image>-arm64`), each with its own duplicated
  `requires:` chain — roughly doubling the workflow's job count and ~200 lines of near-identical YAML in
  `.circleci/config.yml`.
- Each arch pushes independently, so a partial failure (amd64 push succeeds, arm64 push fails, or vice versa)
  can leave the repo in a broken half-released state — no atomicity across the two tags.
- Because internal Dockerfiles reference their parent image by an unsuffixed tag (e.g.
  `FROM darthjee/ruby_331:1.1.1`), and today's arm64 build pushes that parent under a *different* tag
  (`darthjee/ruby_331:1.1.1-arm64`), an arm64 build of a chained image (e.g. `rails_gems`) may actually be
  resolving its `FROM` to the amd64 image rather than a true arm64 parent — there's no unified manifest
  uniting both archs under one tag for it to resolve against correctly. Unverified against an actual build,
  and explicitly not chased down further as part of this issue (see Backward compatibility, under Solution).

## Expected Behavior

- Each image builds and pushes via a single `docker buildx build --platform linux/amd64,linux/arm64 --push`
  invocation, producing one multi-platform manifest under one unsuffixed tag.
- A single CI job per image runs this, replacing today's `release-<image>` / `release-<image>-arm64` pair.
- Both `amd64` and `arm64` are pullable from that same unsuffixed tag, verified on real hosts of both
  architectures.
- A failed build/push for either platform fails the whole operation — no partial, half-released state.

## Solution

Evaluate replacing the QEMU-binfmt + per-arch `docker build --platform` pattern with
`docker buildx build --platform linux/amd64,linux/arm64 --push` — a single build invocation that produces one
multi-platform manifest and a single push, with better cross-platform layer caching than today's approach.
Prototype it against at least one image in this repo (e.g. `scripts` or `node`), confirm both `amd64` and
`arm64` are pullable from the same unsuffixed tag, and if it proves out, roll it out across this repo's
`bin/image.sh`, then majora, then oak.

### CI job topology

Today each image gets two CircleCI jobs off the shared `release` job template — `release-<image>` (default
`PLATFORM=linux/amd64`) and `release-<image>-arm64` — each with its own `requires:` chain mirroring the other
(e.g. `release-ruby_331` requires `release-scripts`, `release-ruby_331-arm64` requires `release-scripts-arm64`).
Both run a "Set up QEMU" step (`docker run --privileged --rm tonistiigi/binfmt --install all`) followed by
`bin/image.sh push <image> [arch]` on the `machine: true` executor.

Decision: collapse this to a single `release-<image>` job per image.

- `docker buildx build --platform linux/amd64,linux/arm64 ... --push` builds *both* platforms inside one
  invocation (still using QEMU emulation for the arm64 leg on the amd64 CI host) and pushes one multi-platform
  manifest under one tag — there's no more "build amd64" / "build arm64" as separate steps or separate script
  calls the way `bin/image.sh`'s current per-arch `build()` does it.
- The `-arm64` job variants and their duplicate `requires:` chains go away entirely; each image keeps a single
  `requires:` chain. This roughly halves the workflow's job count and removes the ~200 lines of `-arm64`
  duplication in `.circleci/config.yml`.
- The job still needs the QEMU registration step (cross-building arm64 via emulation on an amd64 host isn't
  going away), plus a new bootstrap step to create/select a buildx builder (`docker buildx create --use`),
  since the default `docker` driver can't produce a multi-platform `--push`. Whether the `machine` executor's
  image already ships the `docker buildx` CLI plugin is a prototype-validation item, not assumed here.
- `bin/image.sh` gets a new buildx-based push function (no `arch` argument) used by the CI path. The existing
  single-arch `build()`/`tag()` functions are kept as-is for local single-platform debug builds (fast
  iteration on one image without going through buildx/push) — two code paths by design, not an oversight.

### `circleci/docker` orb decision

Deferred — explicitly out of scope for this issue.

`bin/image.sh` carries repo-specific logic the orb doesn't replicate out of the box: `image_version` (reads
the target version from the `version` file per image), `skip_if_unchanged` (skips a release when nothing
changed under `$image/$version/` since the previous git tag), and `image_test` (docker-compose-driven image
testing). Adopting `circleci/docker`'s `docker/publish` job wholesale would mean re-implementing all three
around it, which isn't a quick win alongside the buildx migration and deserves its own investigation. oak#218
is already investigating the same orb-vs-hand-rolled question for oak specifically; revisit this decision once
that lands findings, rather than duplicating the investigation here.

### Rollout plan

- **docker (this repo)** — in scope for this issue, beyond just the prototype: once the buildx approach is
  validated on the prototype image, roll it out to every image's CI job in this repo (per the collapsed CI job
  topology above).
- **majora** — separate follow-up, not yet opened. Majora inherits the same `bin/image.sh`/CI pattern from
  this repo; its buildx migration follows once this issue lands, as its own issue.
- **oak** — spun off now as darthjee/oak#243 ("Port docker buildx multi-arch build pattern from
  darthjee/docker#139"), rather than waiting. oak#217 (closed) deliberately ported the old QEMU + per-arch
  pattern to oak for consistency with this repo, and oak#218 (open) is independently investigating the
  `circleci/docker` orb question for oak — darthjee/oak#243 notes both and defers oak's own orb-vs-buildx
  choice to be reconciled when it's picked up, rather than gating on either landing first.

### Edge cases

- **arm64 base-image/emulation support is already proven, not a new risk.** Every image in `version` already
  has both an amd64 and an arm64 CI job today (checked `.circleci/config.yml`), and both already build under
  QEMU emulation. Buildx doesn't change what gets emulated or which base images are used — only how the build
  is invoked — so "does this image's base support arm64" / "does emulation break this image's native
  compilation" aren't new blockers to re-litigate during rollout; the current pipeline has already answered
  both for every image.
- **Atomic push (an improvement).** Today, `push()` runs independently per arch/job — if the amd64 push
  succeeds and the arm64 push fails (or vice versa), the repo can land in a broken half-released state
  (`:version` exists but `:version-arm64` doesn't, or the two point at inconsistent content).
  `docker buildx build --platform ... --push` pushes the whole multi-platform manifest as one atomic
  operation: either everything lands or nothing does.
- **`--push` and `--load` are mutually exclusive for multi-platform builds.** buildx can't simultaneously push
  a multi-platform manifest *and* load a copy into the local Docker daemon for inspection (`--load` only ever
  works single-platform). This directly constrains how `bin/image.sh test`/`image_test` can work post-
  migration — captured here as a constraint; resolving it is part of implementation planning.

### Backward compatibility

- No internal consumer of the `-arm64` suffixed tag was found in this repo — grepped Dockerfiles, `Makefile`,
  scripts, and `README.md`; every internal `FROM` line references the unsuffixed tag (e.g.
  `FROM darthjee/scripts:0.7.0`). Any consumer in majora/oak or elsewhere pinning to a `-arm64` tag directly is
  out of scope to hunt down from here — handled where it's used, not gated on this issue.
- See Problem above for the possible existing correctness bug this uncovered (chained internal `FROM`s
  possibly resolving to the wrong arch today) — unverified, and explicitly deferred to be fixed later, where
  it's used, rather than as part of this issue's scope.

## Acceptance Criteria

- [ ] buildx-based build/push prototyped for at least one image in this repo
- [ ] Multi-arch manifest correctness confirmed (single tag resolves correctly on both amd64 and arm64 hosts)
- [x] Decision recorded on orb adoption (`circleci/docker`) vs keeping the hand-rolled script — deferred, see
      `circleci/docker` orb decision above
- [ ] CI job topology collapsed to one buildx job per image, and `bin/image.sh` split into a buildx CI path +
      kept local single-arch debug path, rolled out across all of this repo's images (not just the prototype)
- [x] Rollout plan written for docker → majora → oak — see Rollout plan above; oak's follow-up already opened
      as darthjee/oak#243, majora's left for a later follow-up

## Benefits

- Roughly halves this repo's CircleCI job count and removes ~200 lines of duplicated `-arm64` YAML.
- Atomic multi-arch push — no more risk of a half-released image where one arch's tag exists and the other's
  doesn't.
- Better cross-platform layer caching than today's two fully independent `docker build` invocations.
- Likely fixes a latent correctness gap where chained internal images may currently resolve `FROM` to the
  wrong architecture under the old per-tag-per-arch scheme.
- A validated pattern that can propagate outward to majora and oak, both of which inherit this repo's release
  mechanism.
