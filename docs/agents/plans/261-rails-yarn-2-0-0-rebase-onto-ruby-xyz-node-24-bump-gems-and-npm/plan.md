# Plan: rails_yarn 2.0.0: rebase onto ruby_node 2.0.0, Node 24, bump gems and npm

Issue: [261-rails-yarn-2-0-0-rebase-onto-ruby-xyz-node-24-bump-gems-and-npm.md](../../issues/261-rails-yarn-2-0-0-rebase-onto-ruby-xyz-node-24-bump-gems-and-npm.md)

## Overview
Create `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn` `2.0.0` on top of the `ruby_node:2.0.0` family (Ruby 3.4.12, Node 24, `ncat`), install only `telnet` + Yarn `1.22.22` on top, harden the Dockerfiles, bump gems (Rails 7.2.4, aligned with `rails_gems 3.0.0`) and `js-cookie`, and wire the new versions into `version`, CircleCI and docs.

See [ruby-node.md](ruby-node.md) for the full plan. Step 05 (root wiring: `.circleci/config.yml` and root docs) is outside the `ruby-node` agent's scope and is done by the architect.
