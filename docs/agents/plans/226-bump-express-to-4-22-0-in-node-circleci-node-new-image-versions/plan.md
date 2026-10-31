# Plan: Bump express to 4.22.0 in node / circleci_node (new image versions)

Issue: [226-bump-express-to-4-22-0-in-node-circleci-node-new-image-versions.md](../../issues/226-bump-express-to-4-22-0-in-node-circleci-node-new-image-versions.md)

## Overview
Create version 0.2.4 of `node` and `circleci_node` that pins `express` to 4.22.0 (CVE-2024-51999). `node` 0.2.4 also moves to `darthjee/scripts:0.11.0`. All the work is inside the `node` agent's image folders.

See [node.md](node.md) for the full plan.
