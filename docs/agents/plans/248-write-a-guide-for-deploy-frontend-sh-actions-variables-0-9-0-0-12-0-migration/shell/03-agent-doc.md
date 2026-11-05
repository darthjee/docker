# Agent doc: docs/agents/deploy_frontend.md

Create `docs/agents/deploy_frontend.md`, written for LLM agents (precise, example-driven):

1. **Reference pointer**: "The reference (actions, variables, staging model, failure and recovery, CircleCI example) is the `deploy_frontend.sh` section of `scripts/<version>/README.md`, with `<version>` from the `scripts=` line of the root `version` file." Do not hard-code `0.12.0`, and do not repeat the README tables.
2. **Version note**: 0.10.0 is byte-identical to 0.9.0; 0.11.0 → 0.12.0 only adds `cleanup`.
3. **Migration table** (0.9.0/0.10.0 → 0.12.0): rows 1–11 exactly as verified in the issue's "Findings to include" section, plus its "Not a difference" note.
4. **Migration checklist**: the six steps from the issue.
5. **Other gotchas** from the issue (`BUILD_COMMAND` in images without node such as `darthjee/tent`, `$HOME` writable, `COMMAND` quoting), each linking to the README where it covers them. Link the README's `cleanup` glob caveat rather than restating it.

Placeholders only: no real hosts or keys.

## Files to Change
- `docs/agents/deploy_frontend.md` — new file.
