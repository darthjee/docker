# Update docs and open follow-up issues

- `docs/agents/architecture.md` testing section: describe the single test path (own `test/Dockerfile` or `Dockerfile.test`, always runs `/home/test/test.sh`, skip when no `test/`), that `bin/script.sh build` stops at the first failure and exits non-zero (including the pinned-base check), and that `test/` changes don't trigger a re-push. Remove the "Images without that file are tested exactly as before" sentence.
- `docs/agents/contributing.md` (Versioning): if it says any change to a published version folder means a new version or re-push, note that `test/` and `README.md` are exceptions.
- After the specialists finish, open follow-up issues for every image they reported as already broken, using `spawn_issue.sh` (comment cross-reference to #205, not a sub-issue). List them in the PR description.

## Files to Change
- `docs/agents/architecture.md` — testing and build sections
- `docs/agents/contributing.md` — versioning exception for `test/`, only if needed
