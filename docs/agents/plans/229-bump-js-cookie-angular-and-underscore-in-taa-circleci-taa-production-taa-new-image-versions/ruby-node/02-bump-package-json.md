# Bump package.json pins
In each of the three `1.7.0/home/package.json` files, set:
- `js-cookie`: `3.0.7`
- `angular`: `1.8.3`
- `angular-route`: `1.8.3` (kept the same as `angular`)
- `underscore`: `1.13.8`
- `jquery`: `3.7.1`

Leave `yarn` (1.22.22), `bootstrap` (4.6.2), `cyberhawk` (0.8.0) and `johto` (^0.0.1) unchanged. Then check that the shared pins (`yarn`, `underscore`, `bootstrap`, `jquery`, `js-cookie`) match `rails_yarn/1.3.0/home/package.json` exactly. All three variants must end up with identical `package.json` files.

## Files to Change
- `taa/1.7.0/home/package.json` — bumped pins
- `circleci_taa/1.7.0/home/package.json` — bumped pins
- `production_taa/1.7.0/home/package.json` — bumped pins
