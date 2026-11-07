# Write the image READMEs
Rewrite each copied `README.md` per `docs/agents/image-readme.md`:

- the title and Docker Hub badge use the new image name (`darthjee/ruby_3412`, …);
- "About the image" names `ruby:3.4.12` / `cimg/ruby:3.4.12`;
- the gem lists match the new Gemfile;
- `## Included scripts` matches the `COPY --from=scripts` lines;
- for circleci, drop any mention of `cc-test-reporter`;
- the counterpart links point at `circleci_ruby_3412` / `production_ruby_3412` / `ruby_3412`.

If `check_readme.sh` applies, run it.

## Files to Change
- `ruby_3412/1.0.0/README.md`
- `circleci_ruby_3412/1.0.0/README.md`
- `production_ruby_3412/1.0.0/README.md`
