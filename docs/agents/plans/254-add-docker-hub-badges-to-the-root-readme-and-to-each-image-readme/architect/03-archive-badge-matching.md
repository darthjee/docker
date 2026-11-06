# archive.sh badge matching

In `bin/archive.sh`, `remove_from_readme` currently does:

```bash
grep -v "^  - \[${image}:" README.md > aux
```

That no longer matches a badge line. Change it to match on the Docker Hub link, as a fixed string so the `.` in the URL and the `[`/`(` characters are not read as regex:

```bash
grep -v -F "(https://hub.docker.com/r/darthjee/${image})" README.md > aux
```

The closing `)` keeps the match exact: archiving `node` must not remove `node_mongo` or `circleci_node`.

Check it by hand (no automated tests exist): on a scratch copy of the updated README, run the `grep` for `node` and confirm only the `node` line goes. Then run it for `circleci_node` and confirm only that line goes.

## Files to Change
- `bin/archive.sh` — `remove_from_readme` matches the Docker Hub badge link.
