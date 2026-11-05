# Architect Plan: deploy_frontend.sh: KEEP_OLD=<n> to keep only the newest N _old_* folders

Main plan: [plan.md](plan.md)

## Shared contracts

You rely on the shell agent shipping the `KEEP_OLD` behaviour in the table in [plan.md](plan.md#shared-contracts), in scripts `0.14.0`, with the root `version` file at `scripts=0.14.0`. Describe it with exactly those semantics.

## Implementation Steps

### Step 1 — Document 0.14.0 in the guide
In `docs/agents/deploy_frontend.md`:
- `## Reference`: mention that `### Failure and recovery` now covers `KEEP_OLD=<n>` retention.
- `## Versions`: add "0.13.0 → 0.14.0: `release` accepts `KEEP_OLD=<n>` …; no breaking changes, except that an invalid `KEEP_OLD` value (anything other than unset/`true`/`false`/a non-negative integer) now makes `release` fail before touching anything, where 0.13.0 treated it as `false`."
- Add a `## Migration: 0.13.0 → 0.14.0` section after the 0.12.0 → 0.13.0 one: the `KEEP_OLD` table in short form, the invalid-value note above, and a suggestion to replace `KEEP_OLD=true` plus manual pruning with e.g. `KEEP_OLD=3`.
- Update the earlier migration header/intro wording so 0.14.0 is covered (e.g. "Everything below also applies to 0.13.0 and 0.14.0").
- `## Out of scope here`: drop the "#250" open item. Keep the `rollback` action as a possible follow-up if it is listed there.

Commit as `docs(architect): Document KEEP_OLD=<n> in deploy_frontend guide (issue #250)`.

## Files to Change
- `docs/agents/deploy_frontend.md` — 0.14.0 version note, migration section, removed #250 pointer

## Notes
- Do this after the shell agent's README step, and check the wording against the final `scripts/0.14.0/README.md`.
- At the end, remove the planning artifacts, as in #249 (`chore(docs): remove planning artifacts`), if the pipeline expects it.
