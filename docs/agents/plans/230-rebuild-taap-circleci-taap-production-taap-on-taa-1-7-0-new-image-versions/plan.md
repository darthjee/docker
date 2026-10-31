# Plan: Rebuild taap / circleci_taap / production_taap on taa 1.7.0 (new image versions)

Issue: [230-rebuild-taap-circleci-taap-production-taap-on-taa-1-7-0-new-image-versions.md](../../issues/230-rebuild-taap-circleci-taap-production-taap-on-taa-1-7-0-new-image-versions.md)

## Overview
Create `taap`, `circleci_taap` and `production_taap` **1.7.0** from the already-published 1.6.0. Rebase them on `taa` / `circleci_taa` / `production_taa` 1.7.0 (#229), so they inherit the js-cookie 3 / angular 1.8 bumps that supersede Dependabot PRs #125 and #138.

See [ruby-node.md](ruby-node.md) for the full plan.
