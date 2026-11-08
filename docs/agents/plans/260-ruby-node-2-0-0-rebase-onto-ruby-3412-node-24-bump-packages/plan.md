# Plan: ruby_node 2.0.0: rebase onto ruby_3412, Node 24, bump packages

Issue: [260-ruby-node-2-0-0-rebase-onto-ruby-3412-node-24-bump-packages.md](../../issues/260-ruby-node-2-0-0-rebase-onto-ruby-3412-node-24-bump-packages.md)

## Overview
Create `ruby_node`, `circleci_ruby_node` and `production_ruby_node` `2.0.0` on top of the published `ruby_3412:1.0.0` family, install Node 24 from nodesource (bundled npm, no `npm install.sh`), delete the unused `home/` Gemfile, harden the install `RUN`, add version-asserting subtests, and wire the new versions into `version`, CircleCI and docs.

See [ruby-node.md](ruby-node.md) for the full plan. Step 05 (root wiring: `.circleci/config.yml` and root docs) is outside the `ruby-node` agent's scope and is done by the architect.
