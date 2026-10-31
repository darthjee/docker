# Plan: Rebuild node_mongo / circleci_node_mongo on node 0.2.4 (new image versions)

Issue: [227-rebuild-node-mongo-circleci-node-mongo-on-node-0-2-4-new-image-versions.md](../../issues/227-rebuild-node-mongo-circleci-node-mongo-on-node-0-2-4-new-image-versions.md)

## Overview
Create version 0.2.3 of `node_mongo` and `circleci_node_mongo`, rebuilt on `darthjee/node:0.2.4` / `darthjee/circleci_node:0.2.4` so they inherit the `express` 4.22.0 fix (CVE-2024-51999).

See [node.md](node.md) for the full plan.
