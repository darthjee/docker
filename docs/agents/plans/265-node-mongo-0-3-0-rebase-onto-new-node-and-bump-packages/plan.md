# Plan: node_mongo 0.3.0: rebase onto new node and bump packages

Issue: [265-node-mongo-0-3-0-rebase-onto-new-node-and-bump-packages.md](../../issues/265-node-mongo-0-3-0-rebase-onto-new-node-and-bump-packages.md)

## Overview
Create `node_mongo/0.3.0` and `circleci_node_mongo/0.3.0`, rebased onto `node:0.3.0` / `circleci_node:0.3.0` (#264). Both images move to MongoDB apt series `9.0` and pin `mongodb-mongosh` 2.14.1 and `mongodb-database-tools` 100.20.1 exactly.

See [node.md](node.md) for the full plan.
