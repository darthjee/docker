# Plan: Bump js-cookie, underscore and jquery in rails_yarn / circleci_rails_yarn / production_rails_yarn (new image versions)

Issue: [228-bump-js-cookie-and-underscore-in-rails-yarn-circleci-rails-yarn-production-rails-yarn-new-image-versions.md](../../issues/228-bump-js-cookie-and-underscore-in-rails-yarn-circleci-rails-yarn-production-rails-yarn-new-image-versions.md)

## Overview
Release `rails_yarn`, `circleci_rails_yarn` and `production_rails_yarn` **1.3.0**, copied from 1.2.1. The new version pins `js-cookie` 3.0.7 (fixes CVE-2026-46625), `underscore` 1.13.8 and `jquery` 3.7.1. It supersedes Dependabot PRs #119, #120, #122 and #124.

See [ruby-node.md](ruby-node.md) for the full plan.
