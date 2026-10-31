#!/bin/bash

# The image ships no Gemfile.lock, so a bare `bundle check` resolves against
# the live rubygems index and fails as soon as an unpinned transitive
# dependency gets a newer release. Resolving offline needs every group to be
# installed, but development/test gems are left out of the production image on
# purpose. So check a copy of the Gemfile reduced to the runtime (default
# group) dependencies, locked offline against the installed gems.

CHECK_DIR=$(mktemp -d)

ruby -rbundler -e '
  dsl = Bundler::Dsl.new
  dsl.eval_gemfile(ARGV[0])
  puts "source \"https://rubygems.org\""
  dsl.dependencies.select { |dep| dep.groups.include?(:default) }.each do |dep|
    puts "gem #{dep.name.inspect}, #{dep.requirement.as_list.map(&:inspect).join(", ")}"
  end
' /home/app/app/Gemfile > "$CHECK_DIR/Gemfile" && \
  bundle lock --local --gemfile="$CHECK_DIR/Gemfile" && \
  bundle check --gemfile="$CHECK_DIR/Gemfile"
