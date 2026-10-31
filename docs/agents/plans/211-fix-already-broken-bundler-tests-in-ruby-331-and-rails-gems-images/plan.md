# Plan: Fix already-broken bundler tests in ruby_331 and rails_gems images

Issue: [211-fix-already-broken-bundler-tests-in-ruby-331-and-rails-gems-images.md](../../issues/211-fix-already-broken-bundler-tests-in-ruby-331-and-rails-gems-images.md)

## Overview
Make the `bundler.sh` subtest pass for `ruby_331`, `circleci_ruby_331`, `production_ruby_331`, `rails_gems` and `circleci_rails_gems`. Three changes: a `Gemfile.lock` in new image versions, the duplicate `rubocop-rspec` removed, and the production test scoped to the groups the image installs. All work is in the `ruby` agent's scope.

See [ruby.md](ruby.md) for the full plan.
