# Remove the CircleCI release job safely

The `release` workflow's first job, `release-fly`, defines the YAML anchor used by every other job:

```yaml
      - release:
          name: release-fly
          image: fly
          filters: &tag_only
            tags:
              only: /.*/
            branches:
              ignore: /.*/
```

Move the anchor definition onto the next job, `release-scripts` (replace its `filters: *tag_only` with the full `filters: &tag_only` block above), then delete the `release-fly` job. Nothing `requires: [release-fly]`, so no dependency edges change. Keep the `# ── Tools ──` comment header.

Validate the result (`circleci config validate` if available, or a YAML parse with aliases enabled) and confirm every `*tag_only` alias still resolves.

## Files to Change
- `.circleci/config.yml` — move `&tag_only` to `release-scripts`, remove the `release-fly` job.
