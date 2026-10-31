# Update the READMEs
Following `docs/agents/image-readme.md`, update each copied `1.7.0/README.md` to mention that this version upgrades `js-cookie` to 3.x and `angular` / `angular-route` to 1.8.x (both breaking for downstream apps), bumps `underscore` and `jquery`, and is built on `rails_yarn` 1.3.0. Keep the rule of no hardcoded version tags in the usage examples (#173): use `<version>` there.

## Files to Change
- `taa/1.7.0/README.md` — note the upgrades
- `circleci_taa/1.7.0/README.md` — note the upgrades
- `production_taa/1.7.0/README.md` — note the upgrades
