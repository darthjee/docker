# Plan: taa 2.0.0: rebase onto new rails_yarn and bump dependencies

Issue: [262-taa-2-0-0-rebase-onto-new-rails-yarn-and-bump-dependencies.md](../../issues/262-taa-2-0-0-rebase-onto-new-rails-yarn-and-bump-dependencies.md)

## Overview
Create `taa`, `circleci_taa` and `production_taa` 2.0.0 on top of `{,circleci_,production_}rails_yarn:2.0.0` and `scripts:0.15.0`, align the Gemfile with `rails_yarn 2.0.0` on Ruby 3.4.12, bump `js-cookie`, and apply the Dockerfile hardening used in #261. All work belongs to the `ruby-node` agent.

See [ruby-node.md](ruby-node.md) for the full plan.
