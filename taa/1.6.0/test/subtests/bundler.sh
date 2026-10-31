#!/bin/bash

# The image ships no Gemfile.lock, so a bare `bundle check` resolves against
# the live rubygems index and fails as soon as an unpinned transitive
# dependency gets a newer release. Lock offline against the installed gems
# first, then check.
bundle lock --local --gemfile=/home/app/app/Gemfile && \
  bundle check --gemfile=/home/app/app/Gemfile
