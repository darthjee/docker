# Root README badges

In the root `README.md` `## Images` section, replace each entry's hardcoded `[<image>:<version>](https://hub.docker.com/repository/docker/darthjee/<image>)` link with the badge from the shared contract. Keep the list structure, the indentation (`  - `), the group headings (`#### Tools`, `### Development`, `### Circleci`, `### Production`) and the order. Keep the trailing `(deprecated, use `python`)` / `(deprecated, use `circleci_python`)` notes after the `python_37` / `circleci_python_37` badges.

Result, e.g.:

```markdown
#### Tools
  - [![docker](https://img.shields.io/docker/v/darthjee/scripts.svg?logo=docker&label=scripts&sort=semver)](https://hub.docker.com/r/darthjee/scripts)
### Development
  - [![docker](https://img.shields.io/docker/v/darthjee/node.svg?logo=docker&label=node&sort=semver)](https://hub.docker.com/r/darthjee/node)
  - [![docker](https://img.shields.io/docker/v/darthjee/python_37.svg?logo=docker&label=python_37&sort=semver)](https://hub.docker.com/r/darthjee/python_37) (deprecated, use `python`)
```

Check that the list has exactly the 32 images in `version`, one line each, in the right group (the list currently matches `version`; add or drop lines if not).

## Files to Change
- `README.md` — badges replace the hardcoded image links in `## Images`.
