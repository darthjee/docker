# Plan: Warm yarn cache unused in circleci_rails_yarn/taa/taap (wrong cache dir for circleci user)

Issue: [217-warm-yarn-cache-likely-unused-in-circleci-rails-yarn-taa-taap-wrong-cache-dir-for-circleci-user.md](../../issues/217-warm-yarn-cache-likely-unused-in-circleci-rails-yarn-taa-taap-wrong-cache-dir-for-circleci-user.md)

## Overview
Release patch versions `circleci_rails_yarn` 1.1.1, `circleci_taa` 1.5.1 and `circleci_taap` 1.5.1 that put the warm yarn cache in `/home/circleci/.cache/yarn/v6/` (yarn's cache dir for the `circleci` user), on the latest bases, with tests and corrected READMEs.

See [ruby-node.md](ruby-node.md) for the full plan.
