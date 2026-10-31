# Plan: Align rails_bower Gemfile pins with ruby_331 so its Gemfile.lock is a pure delta

Issue: [232-align-rails-bower-gemfile-pins-with-ruby-331-so-its-gemfile-lock-is-a-pure-delta.md](../../issues/232-align-rails-bower-gemfile-pins-with-ruby-331-so-its-gemfile-lock-is-a-pure-delta.md)

## Overview
Release rails_bower 2.0.0 (dev, circleci, production). Its Gemfile pins match the gem versions ruby_331 1.2.0 already installs, and its shipped `Gemfile.lock` is a pure delta over the parent's lockfile.

See [ruby-node.md](ruby-node.md) for the full plan.
