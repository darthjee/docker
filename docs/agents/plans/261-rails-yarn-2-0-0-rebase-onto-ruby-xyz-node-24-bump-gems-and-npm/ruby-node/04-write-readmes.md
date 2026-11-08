# Rewrite the READMEs
Update the three `2.0.0/README.md` per `docs/agents/image-readme.md`:

- Parent is now `darthjee/ruby_node` / `circleci_ruby_node` / `production_ruby_node` (link to Docker Hub), giving Ruby 3.4.12 and Node 24; the image adds Yarn 1.22.22, `telnet`, the pre-cached front-end packages and the Rails gem set.
- Update listed versions (Ruby, Node, Yarn, Rails 7.2.4, front-end packages, notable gems) to match step 03.
- Keep the badges, usage examples and counterpart tables.

## Files to Change
- `rails_yarn/2.0.0/README.md`, `circleci_rails_yarn/2.0.0/README.md`, `production_rails_yarn/2.0.0/README.md`
