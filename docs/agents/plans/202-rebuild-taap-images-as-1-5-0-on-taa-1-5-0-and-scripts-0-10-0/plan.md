# Plan: Rebuild taap images as 1.5.0 on taa 1.5.0 and scripts 0.10.0

Issue: [202-rebuild-taap-images-as-1-5-0-on-taa-1-5-0-and-scripts-0-10-0.md](../../issues/202-rebuild-taap-images-as-1-5-0-on-taa-1-5-0-and-scripts-0-10-0.md)

## Overview
Publish `taap`, `circleci_taap` and `production_taap` 1.5.0, built on `taa:1.5.0` (and its circleci/production versions) and `scripts:0.10.0`. The rewrite drops the old Gemfile, Bower and yarn steps, copies the bundle the same way `taa` 1.5.0 does so `danica` and `gnuplot` are actually installed, and adds tests that fail when they are missing. All the work is in the `ruby-node` agent's image folders.

See [ruby-node.md](ruby-node.md) for the full plan.
