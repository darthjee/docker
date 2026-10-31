# Plan: Fix already-broken bundler tests in ruby-node images

Issue: [212-fix-already-broken-bundler-tests-in-ruby-node-images.md](../../issues/212-fix-already-broken-bundler-tests-in-ruby-node-images.md)

## Overview
Make `bin/script.sh test ruby_node taa taap rails_bower rails_yarn` exit 0 for every pinned version. Three changes only touch tests (ruby_node, circleci_taa, production_taa). rails_yarn needs a new 1.1.1 image for all three variants.

See [ruby-node.md](ruby-node.md) for the full plan.
