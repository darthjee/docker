# Update the READMEs
In each new `README.md`, add a short note (following `docs/agents/image-readme.md`) saying the JS packages inherited from the base are upgraded in this version: `angular` / `angular-route` 1.8 (breaking compared with 1.4), `js-cookie` 3 (breaking compared with 2) and `jquery` 3.7. Say that these come from `darthjee/<variant>taa` 1.7.0 and link to that image's Docker Hub page, which has the full note and migration links. Base the wording on the note in `taa/1.7.0/README.md` (the paragraph under the package list), but keep it shorter and pointing at `taa` instead of repeating the migration details. Put it in the "Pre-installed gems and pre-cached packages" section (or its equivalent in the circleci/production READMEs).

Make sure each README's base-image references still name the right base (`taa` / `circleci_taa` / `production_taa`).

## Files to Change
- `taap/1.7.0/README.md`: inherited JS upgrade note
- `circleci_taap/1.7.0/README.md`: inherited JS upgrade note
- `production_taap/1.7.0/README.md`: inherited JS upgrade note
