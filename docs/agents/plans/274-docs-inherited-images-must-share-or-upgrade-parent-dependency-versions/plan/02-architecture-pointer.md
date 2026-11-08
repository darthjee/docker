# Point to it from architecture.md

After line 37 of `docs/agents/architecture.md` ("Each image in a hierarchy installs only the delta relative to its parent, so layers accumulate rather than duplicate."), add one sentence. It says that the delta is computed by name and version, so a child must share its parent's dependency versions (or justify a newer one), and it links to `contributing.md#dependency-versions-in-inherited-images`.

## Files to Change
- `docs/agents/architecture.md` — one-sentence pointer after the delta line.
