# Plan: New ruby_3412 image on Ruby 3.4.12

Issue: [258-new-ruby-xyz-image-on-the-latest-stable-ruby.md](../../issues/258-new-ruby-xyz-image-on-the-latest-stable-ruby.md)

## Overview
Create `ruby_3412`, `circleci_ruby_3412` and `production_ruby_3412` at `1.0.0` on Ruby 3.4.12, copied from the `ruby_331/1.2.0` family. The gems are bumped within their current majors (`activesupport` stays on 7.2.x), all three images share one Bundler version, the dead `cc-test-reporter` download is removed, and the Dockerfile syntax is modernised. `ruby_331` is left frozen at `1.2.0`.

See [ruby.md](ruby.md) for the full plan. The image folders belong to the `ruby` agent. The root-level wiring in its last step (`version`, `.circleci/config.yml`, root README, AGENTS.md, `docs/agents/*`, `.claude/agents/ruby.md`) is outside that agent's scope, so the architect does it.
