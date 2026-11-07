# Update the Dockerfiles
Replace both Dockerfiles with the content in the issue's Solution §2:

- `scripts` stage first: `FROM darthjee/scripts:0.15.0 AS scripts`.
- New base: `FROM darthjee/ruby_3412:1.0.0 AS base` / `FROM darthjee/circleci_ruby_3412:1.0.0 AS base`.
- Modern syntax: `AS`, `ENV K=V`.
- `circleci_rails_gems`: remove the `USER root` / `apt-get update && apt-get install -y libsqlite3-dev` / `USER circleci` block (no longer needed with `sqlite3` 2.x) and run `RUN bundle_builder.sh` instead of `RUN /bin/bash bundle_builder.sh`.

Keep the stage layout and copy targets otherwise identical (dev final stage still copies `home/*` to `/home/app/app/`; circleci final stage copies only the bundle).

## Files to Change
- `rails_gems/3.0.0/Dockerfile`
- `circleci_rails_gems/3.0.0/Dockerfile`
