# Wire the spec into agent files and issue-enhancement.md
Point every agent that writes READMEs at the spec, and fix the known inaccuracy in `python.md`.

- `.claude/agents/node.md`, `python.md`, `ruby.md`, `ruby-node.md`, `shell.md`: append to `## Conventions`:
  `- Each image version's `README.md` is the image's Docker Hub description; write and edit it following [docs/agents/image-readme.md](../../docs/agents/image-readme.md).`
  Do not duplicate process details there.
- `.claude/agents/architect.md`: add the same row as in `AGENTS.md` to its `## Documentation (docs/agents/)` table.
- `.claude/agents/python.md` scope list: change the `circleci_python_37/`, `circleci_django/` line so only `circleci_django` is described as based on `cimg` (`cimg/python:3.12`) and `circleci_python_37` as built on the legacy `circleci/python:3.7.2`; both remain parallel, not derived from the dev image.
- `docs/agents/issue-enhancement.md`: add a line (after the checklist) saying that issues adding or editing an image README follow [image-readme.md](image-readme.md), so its conventions need not be re-discussed.

## Files to Change
- `.claude/agents/node.md`, `.claude/agents/ruby.md`, `.claude/agents/ruby-node.md`, `.claude/agents/shell.md` — Conventions bullet.
- `.claude/agents/python.md` — Conventions bullet and scope-line fix.
- `.claude/agents/architect.md` — documentation table row.
- `docs/agents/issue-enhancement.md` — pointer line.
