# Issue: docs: inherited images must share or upgrade parent dependency versions

## Description

Write down the dependency-version rule for inherited images. It goes in three places:

- the full rule in `docs/agents/contributing.md`, under "One responsibility per image";
- a short pointer in `docs/agents/architecture.md`;
- a short reminder in the specialist agent definitions in `.claude/agents/`, so agents see it when they work on an image.

## Problem

A child image copies into its final image only what is new relative to its base. For gems and yarn packages, `bundle_builder.sh` and `yarn_builder.sh` (from the `scripts` image) decide this by name **and** version, e.g. `gems/<name>-<version>`.

A child image (e.g. `taa` on `rails_yarn`, `taap` on `taa`) may pin a dependency the parent already ships at a different version. That version is then copied as new, and the final image carries **both** versions, with the parent's still sitting in the lower layer. With an older version, the child also silently downgrades what the parent provides.

The #256 epic sub-issues (#261, #262, #263) applied this rule by hand, but it is not written down anywhere.

## Expected Behavior

The docs state the rule for **all kinds of dependencies**: gems, npm/yarn packages, pip packages, system packages and so on. It applies to any image built on top of another, and to its `circleci_`/`production_` counterparts:

- A dependency shared with the parent uses **exactly the parent's version**.
- An **older** version is never allowed.
- A **newer** version is a last resort. When a child needs one, first decide which case applies:
  - **The base image needs a new version.** The newer dependency belongs in the parent, so bump the parent image (a new parent version) and rebase the child onto it.
  - **It is a fix specific to the child.** A child-only patch or security fix may pin the newer version in the child, accepting that the parent's copy stays in the image too. Record the reason (in the issue/PR, and in the image README where it makes sense).
- Lock files (`Gemfile.lock`, `yarn.lock`, `requirements` pins, …) are seeded from the parent's lock file, so transitive dependencies match too.

## Solution

- **`docs/agents/contributing.md`:** extend "### One responsibility per image" with the rule above, the decision between bumping the parent and a child-only fix, and why the rule holds: delta copying by name and version, using `bundle_builder.sh`/`yarn_builder.sh` as the concrete example.
- **`docs/agents/architecture.md`:** add one sentence after "Each image in a hierarchy installs only the delta relative to its parent", linking to the contributing rule.
- **`.claude/agents/ruby.md`, `ruby-node.md`, `node.md`, `python.md`:** add a short bullet stating the rule and linking to `docs/agents/contributing.md`.

## Benefits

- Derived images no longer end up with duplicated dependencies or silent downgrades.
- Version bumps go where they belong, in the parent image, instead of piling up in the children.
- Future dependency-bump issues, and the agents working on them, have a written rule to follow instead of re-deriving it each time.
