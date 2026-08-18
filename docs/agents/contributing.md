# Contributing

## Commit Guidelines

- **Atomic and Unitary:** Each commit must represent a single logical change.
  - Good: `Add test for ruby_331 bundler version`
  - Bad: `Add ruby_331 tests and fix circleci_ruby_331 Dockerfile`
- **No Unrelated Changes:** Do not mix unrelated changes in the same commit.
- **Separate Refactoring:** Whenever possible, separate refactoring commits from new feature or bugfix commits.

## Pull Requests

- **Descriptive Summary:** Every PR must include a clear and descriptive summary of its purpose and changes.
- **PR Description Files:** If a description cannot be provided directly in the PR, generate a file with the PR description (e.g., `docs/agents/issues/<pr_number>_description.md`), but do not commit this file.

## Definition of Done for PRs

A PR is considered complete when:

- The stated objective has been achieved.
- All tests pass for every image touched by the change.
- No unintended layers have been added to any image (verify with `docker history`).
- The `version` file is updated if a new image version was released.
- Dockerfiles follow the multi-stage build pattern used by the rest of the repository.

### CI Checks

Before a PR is considered complete, run the following locally for every image you modified:

```bash
bin/script.sh pre_build <image>
bin/script.sh build <image>
bin/script.sh test <image>
```

If you are updating a development image that has CircleCI or production counterparts, also run the same checks for those counterparts:

```bash
bin/script.sh pre_build circleci_<image>
bin/script.sh build circleci_<image>
bin/script.sh test circleci_<image>

bin/script.sh pre_build production_<image>
bin/script.sh build production_<image>
bin/script.sh test production_<image>
```

This same process must be followed when **planning how to resolve an issue**: include a final step in the plan that lists which images are affected and the commands to run before opening a PR.

## Code Organization

### One responsibility per image

Each image should install only the **delta** relative to its parent image. If a dependency belongs to the base (e.g. `ruby_331`), it must not be re-installed in a child image (e.g. `ruby_node`).

### Multi-Stage Builds

All Dockerfiles must use multi-stage builds:
- Use a build stage to compile, install, and configure.
- Copy only the resulting artifacts into the final stage.
- Avoid adding layers that modify or delete files already present in a parent image.

### Shell Scripts (`bin/`)

- Each helper script in `bin/` must do exactly one thing.
- Scripts must be kept small. If a script is growing, extract sub-tasks into separate helper scripts.
- All scripts must be POSIX-compatible bash. Avoid bash-only features when a POSIX equivalent exists.

### `scripts` Image

Shared scripts live in `scripts/<version>/home/sbin/`. They must be general-purpose utilities suitable for use across multiple images. Image-specific logic does not belong in the `scripts` image.

## Versioning

### Fix vs. New Version

An image version that has already been built and published is not altered once it's out — the only exception is fixing that same version (e.g. a bug in the current release). Any other change (adding a dependency, changing behavior, bumping an upstream base image) belongs in a new version. When discussing or planning an issue, explicitly decide which of the two it is before touching image files, since that decision determines whether `bin/script.sh init` is needed at all.

When releasing a new version of an image:

1. Run `bin/script.sh init <image>` to scaffold a new version directory, bumping the current version's minor number automatically. Pass an explicit version instead — `bin/script.sh init <image> <new_version>` — when a specific number is required (e.g. a major bump). Either form copies the current version's files into the new version directory as a starting point.
2. Make your changes in the new version directory.
3. Update the `version` file to reflect the new version.
4. Run `bin/script.sh release <image>` to build and push.

## Refactoring Guidelines

When refactoring Dockerfiles or build scripts, aim to:

- **Reduce layer count:** Combine related `RUN` commands where doing so doesn't reduce clarity.
- **Avoid duplication:** If the same installation logic appears in both a dev and a production image, extract it into a shared base or the `scripts` image.
- **Preserve test coverage:** Every refactored image must still pass `bin/script.sh test <image>` without modification to the tests.
