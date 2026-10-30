# Issue: Add README.md for darthjee/circleci_taap

## Description

Add `circleci_taap/1.4.2/README.md` describing the `darthjee/circleci_taap` image, so it can be pushed as the Docker Hub description of `darthjee/circleci_taap` (see `bin/push_description.sh`). Today the image has no README, so its Docker Hub page has no description, and `bin/script.sh push_description` fails for its family.

Write it following [`docs/agents/image-readme.md`](../image-readme.md), reusing the wording of the `darthjee/taap` README (#168) and the structure of the merged `circleci_rails_bower/1.4.0/README.md` (#166) for the CircleCI parts. The README describes **what the published image really ships**, not what `home/Gemfile` intends (see #199).

## Facts from the image (`circleci_taap/1.4.2/Dockerfile` and the published `darthjee/circleci_taap:1.4.2`)

- Built `FROM darthjee/circleci_taa` (link https://hub.docker.com/r/darthjee/circleci_taa, no tag), the CircleCI Rails + AngularJS image, which provides Ruby 3.3.1, Node.js and Yarn.
- It is the CircleCI counterpart of [`darthjee/taap`](https://hub.docker.com/r/darthjee/taap), but it is **not** built on top of it.
- Default user `circleci`; working directory `/home/circleci/project`, owned by `circleci`.
- Adds the **`gnuplot`** command-line tool, installed with `apt-get` in the final stage. This is the only addition that actually ships.
- Gems: everything in `/home/circleci/.rubygems` (`GEM_HOME`) comes from `darthjee/circleci_taa`, including the development and test groups. The `danica` and `gnuplot` gems listed in `home/Gemfile` are **not** in the published image (#199, the same defect as #197 for `taap`), so the README must not list them.
- Node packages: the ones in `/usr/lib/node_modules` (AngularJS and friends) are inherited from `darthjee/circleci_taa`. `home/bower.json` is copied but never used; ignore it.

## Sections to write

- Title `darthjee/circleci_taap`, underlined with `=` to its length.
- **About the image:** a CircleCI-optimized image for Rails applications with an AngularJS front end that also need plotting, built on top of [`darthjee/circleci_taa`](https://hub.docker.com/r/darthjee/circleci_taa), adding `gnuplot`. Then the counterpart paragraph (CircleCI counterpart of `darthjee/taap`, not built on top of it). Then the `circleci` user/working-directory paragraph.
- **What is added:** the `gnuplot` tool, on top of everything `darthjee/circleci_taa` provides.
- **Pre-installed gems / packages:** no lists. One sentence saying the gems (in `/home/circleci/.rubygems`) and Node packages (in `/usr/lib/node_modules`) are the ones inherited from `darthjee/circleci_taa`, with a link to it.
- **How to use:** link to https://hub.docker.com/r/darthjee/circleci_taap/tags, then the two usages from `circleci_rails_bower` without the Bower parts:
  1. As the CircleCI job executor (`image: darthjee/circleci_taap:<version>`, steps `checkout`, `bundle install`, `bundle exec rspec`).
  2. As a base `Dockerfile`:

     ```dockerfile
     FROM darthjee/circleci_taap:<version>

     COPY --chown=circleci:circleci Gemfile Gemfile.lock /home/circleci/project/
     RUN bundle install
     ```

  Then the gem-reuse sentence. Make no claim about Yarn reusing the global Node packages.
- No `Variants` table.
- **License:** "See the LICENSE file for more information."

## Process

- Add the file **in place** in `circleci_taap/1.4.2/`: no `bin/script.sh init`, no version bump, no `pre_build`/`build`/`test`. `README.md` sits beside `home/` and is never copied into the image.
- No hardcoded `darthjee/` tags, no gem/package/tool versions (Ruby 3.3.1 is allowed as part of the base's identity), no architecture claims, absolute links only.
- Do not use `circleci_taa/1.5.0/README.md` or `circleci_rails_gems`'s README as templates: they predate the spec. Do not edit `circleci_taa`'s README.
- Write in English.

## Dependencies

- #168 (`taap` README): reuse its wording so the family stays consistent.
- #199 (missing `danica`/`gnuplot` gems, the counterpart of #197): independent. When it is fixed, the README should be updated to list the two gems.
- #170 (`production_taap`) is the other counterpart.
- Pushing to Docker Hub is handled separately (#171); this issue only adds the file.

## Responsible agent

`ruby-node`

## Testing

No automated tests. Check the README against the spec's content rules and against the published image (no `danica`/`gnuplot` gems listed). Verified manually once descriptions are pushed: the `darthjee/circleci_taap` Docker Hub page shows this README.

Parent epic: #153
