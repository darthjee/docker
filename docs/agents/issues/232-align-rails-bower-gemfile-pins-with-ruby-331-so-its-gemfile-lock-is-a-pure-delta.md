# Issue: Align rails_bower Gemfile pins with ruby_331 so its Gemfile.lock is a pure delta

## Description
Issue #221 started shipping a `Gemfile.lock` in `rails_bower` 1.6.0 and in its `circleci_` and `production_` variants. The rails_bower Gemfile pins old exact versions, so that lock moves 17 gems away from the versions already installed by the base image, `ruby_331` 1.2.0, which `ruby_node` 1.6.0 is built on. #221 accepted this to keep its change small.

## Problem
Each rails_bower image installs two versions of the moved gems side by side, one from the parent and one from rails_bower. This was already true of the published `darthjee/rails_bower:1.5.0`. Because of it, the shipped lock is not a pure delta over the parent's lockfile.

Gems moved by the rails_bower pins (parent → rails_bower):

- activesupport 7.2.2.1 → 7.0.4.3 (via `rails 7.0.4.3`)
- rake 13.2.1 → 13.1.0
- sinclair 3.1.0 → 2.1.1
- rspec family (6 gems) 3.13.x → 3.12.x
- rubocop 1.85.1 → 1.59.0, rubocop-ast 1.50.0 → 1.30.0
- rubocop-rspec 3.9.0 → 2.29.2
- reek 6.5.0 → 6.1.4 (forces parser 3.3.13.0 → 3.2.2.4)
- rubycritic 5.0.0 → 4.9.1
- yard 0.9.38 → 0.9.36
- unicode-display_width 3.3.0 → 2.6.0 (rubocop 1.59 needs < 3)

## Expected Behavior
- The rails_bower Gemfile pins in all three variants fit the gem versions the parent image already installs.
- The shipped `Gemfile.lock` is a pure delta over the parent variant's lockfile, so no gem the parent installed changes version.
- Plain `bundle check` passes in the dev and circleci images. `BUNDLE_WITHOUT=development:test bundle check` passes in production.

## Solution
- Change the conflicting pins to the parent's versions: rails 7.0.4.3 → 7.2.2.1, rake 13.2.1, sinclair 3.1.0, rspec 3.13.x, rubocop 1.85.1, rubocop-rspec 3.9.0, reek 6.5.0, rubycritic 5.0.0, yard 0.9.38.
- Bump any pin these changes break, such as Rails-coupled gems like `rspec-rails`, `web-console`, `sass-rails` and `rails-controller-testing`, or sinclair dependents like `zyra` and `darthjee-core_ext`.
- Seed the lock from the parent variant's lockfile, the same way #221 did for rails_yarn, taa and taap, then regenerate it.
- Leave the other pins (puma, rack, nokogiri, newrelic_rpm, etc.) unchanged unless the new versions require a bump. Do not add the parent's extra dev gems (simplecov-html, simplecov-lcov, rubocop-rake) to the rails_bower Gemfile.
- Release this as **rails_bower 2.0.0** (also `circleci_rails_bower` and `production_rails_bower` 2.0.0). It is a breaking gem-version change: Rails 7.0 → 7.2, plus major jumps for rubocop, rubocop-rspec and sinclair. Projects built on rails_bower may need changes, so call this out.

## Benefits
- Each rails_bower image carries one version of each gem, which makes the images smaller and the gem set clearer.
- The lockfile approach is the same across the whole Ruby image chain.
