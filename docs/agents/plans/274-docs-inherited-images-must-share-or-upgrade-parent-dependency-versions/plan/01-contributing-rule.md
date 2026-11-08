# Document the rule in contributing.md

Under `### One responsibility per image` in `docs/agents/contributing.md`, keep the existing delta paragraph and add a sub-section `#### Dependency versions in inherited images` with:

- **Why:** builders copy only what is new by name and version (`bundle_builder.sh`'s `gems/<name>-<version>` check, `yarn_builder.sh`'s cache entries, `poetry_builder.sh`). Any version that differs from the parent's is copied again, so the image carries two copies. An older version also silently downgrades what the parent provides.
- **Rule:** applies to all dependency kinds and to `circleci_`/`production_` counterparts:
  1. Shared dependencies use exactly the parent's version.
  2. Never an older version.
  3. A newer version is a last resort. First decide which case applies: either the base image needs a new version (bump the parent and rebase the child onto it), or it is a child-only fix (pin it in the child, accept the duplicate, and record the reason in the issue/PR and, where useful, the README).
  4. Seed the child's lock file (`Gemfile.lock`, `yarn.lock`, `poetry.lock`, …) from the parent's.
- **Example:** `taap` 2.0.0 uses `taa` 2.0.0's Gemfile and lock unchanged, plus `danica`/`gnuplot` (#263).

## Files to Change
- `docs/agents/contributing.md` — new `#### Dependency versions in inherited images` sub-section under "One responsibility per image".
