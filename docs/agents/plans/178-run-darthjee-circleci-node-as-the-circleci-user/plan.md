# Plan: Run darthjee/circleci_node as the circleci user

Issue: [178-run-darthjee-circleci-node-as-the-circleci-user.md](../../issues/178-run-darthjee-circleci-node-as-the-circleci-user.md)

## Overview
Create a new `circleci_node` version (0.2.3) whose final image runs as `circleci`, with the warm yarn cache moved to `/home/circleci/.cache/yarn/v6/` (yarn's cache dir for `circleci`). Add tests that check the runtime user and that the cache is in use, and update the README. All the work is in the `node` agent's scope.

See [node.md](node.md) for the full plan.
