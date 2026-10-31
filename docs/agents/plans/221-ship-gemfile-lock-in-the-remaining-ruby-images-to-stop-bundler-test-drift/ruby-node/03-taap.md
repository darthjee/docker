# taap 1.6.0 on taa 1.6.1 and scripts 0.11.0
Create `taap` 1.6.0 (+circleci/production), moving dev/production off `taa:1.5.0`/`scripts:0.10.0` onto `taa:1.6.1`/`scripts:0.11.0` (circleci goes from `circleci_taa:1.6.0` to `1.6.1`), and ship a lockfile. Use a minor bump because the parent changes a minor version.

1. `bin/script.sh init taap 1.6.0` (only after step 02). Confirm that every `FROM` points at the `*taa:1.6.1` variant and `scripts:0.11.0`.
2. Check the Dockerfiles for anything that relied on `scripts` 0.10.0 vs 0.11.0 (the `COPY --from=scripts` paths should be unchanged).
3. Generate `home/Gemfile.lock` for each variant in its new parent image, seeded from the matching `taa/1.6.1` lockfile.
4. Bundler subtests: dev and circleci use the plain `bundle check`. Production keeps `BUNDLE_WITHOUT=development:test bundle check ...`.
5. Update the READMEs if they mention the old base versions. Build and test all three variants.

## Files to Change
- `taap/1.6.0/`, `circleci_taap/1.6.0/`, `production_taap/1.6.0/` — new version folders (Dockerfile `FROM` updated)
- `*/1.6.0/home/Gemfile.lock` (the three taap variants) — new lockfiles
- `*/1.6.0/README.md` (the three taap variants) — only if they reference the old bases
- `version` — taap variants = 1.6.0
