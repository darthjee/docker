# Update the READMEs

`init` copied each 1.4.2 README into 1.5.0. Edit all three to describe what the 1.5.0 images actually ship, following `docs/agents/image-readme.md` (no `darthjee/` tags, `<version>` placeholders):

- Built on `darthjee/taa` (and its circleci/production versions), with Ruby 3.3.1 and Node.js. No version numbers.
- "What is added": the `danica` and `gnuplot` gems, and the `gnuplot` binary (apt).
- Gems and packages: inherited from `taa`, plus `danica` and `gnuplot`. Fix the 1.4.2 text's paths if they no longer hold (e.g. Node packages are now in the yarn cache `/usr/local/share/.cache/yarn/v6`, not `/usr/lib/node_modules`). Check against `taa/1.5.0/README.md`.
- No Bower or `bower-rails` mentions, and no "changes since 1.4.2" section. Those changes go in the PR description.

## Files to Change
- `taap/1.5.0/README.md`, `circleci_taap/1.5.0/README.md`, `production_taap/1.5.0/README.md` — describe 1.5.0's contents
