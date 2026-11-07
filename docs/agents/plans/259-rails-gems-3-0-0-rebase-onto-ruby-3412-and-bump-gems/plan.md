# Plan: rails_gems 3.0.0: rebase onto ruby_3412 and bump gems

Issue: [259-rails-gems-3-0-0-rebase-onto-ruby-3412-and-bump-gems.md](../../issues/259-rails-gems-3-0-0-rebase-onto-ruby-3412-and-bump-gems.md)

## Overview
Create `rails_gems/3.0.0` and `circleci_rails_gems/3.0.0` on top of the published `ruby_3412:1.0.0` / `circleci_ruby_3412:1.0.0` images and `scripts:0.15.0`, modernise both Dockerfiles, bump the shared Gemfile (Rails 7.2.4, `sqlite3` 2.10.2), and wire the new versions into `version`, CircleCI and docs.

See [ruby.md](ruby.md) for the full plan. Step 05 (root wiring: `.circleci/config.yml` and root docs) is outside the `ruby` agent's scope and is done by the architect.
