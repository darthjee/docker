# Plan: Ship Gemfile.lock in the remaining Ruby images to stop bundler test drift

Issue: [221-ship-gemfile-lock-in-the-remaining-ruby-images-to-stop-bundler-test-drift.md](../../issues/221-ship-gemfile-lock-in-the-remaining-ruby-images-to-stop-bundler-test-drift.md)

## Overview
Release new versions of `rails_yarn`, `taa`, `taap` and `rails_bower` (each with its circleci/production variants) that ship a `home/Gemfile.lock`. Chain the new versions onto the newest parents and simplify the bundler subtests now that a lockfile exists. `ruby_node` is out of scope, since it installs no gems.

See [ruby-node.md](ruby-node.md) for the full plan.
