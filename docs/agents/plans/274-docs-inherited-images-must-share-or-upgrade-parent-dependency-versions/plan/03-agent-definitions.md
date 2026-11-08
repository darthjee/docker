# Add the rule to the specialist agent definitions

In the `## Conventions` list of each specialist agent file, add a bullet right after the existing "installs only the **delta**" bullet:

> Shared dependencies use exactly the parent image's version (never older; newer only after deciding whether the parent needs a new version or it is a child-only fix), and lock files are seeded from the parent's. See [Dependency versions in inherited images](../../docs/agents/contributing.md#dependency-versions-in-inherited-images).

Tailor the lock-file examples to each agent: `Gemfile.lock` for ruby; `Gemfile.lock`/`yarn.lock` for ruby-node; `package-lock.json`/`yarn.lock` for node; `poetry.lock`/`Pipfile.lock` for python.

Leave `shell.md` (the scripts image has no parent dependencies) and `architect.md` alone; the architect reads `contributing.md` directly.

## Files to Change
- `.claude/agents/ruby.md` — new Conventions bullet.
- `.claude/agents/ruby-node.md` — new Conventions bullet.
- `.claude/agents/node.md` — new Conventions bullet.
- `.claude/agents/python.md` — new Conventions bullet.
