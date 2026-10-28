# Remove the CircleCI release job

Delete the `release-heroku` job from the `release` workflow in `.circleci/config.yml`:

```yaml
      - release:
          name: release-heroku
          image: heroku
          filters: *tag_only
```

The `&tag_only` anchor is defined on `release-scripts` (moved there by #154), and no other job lists `release-heroku` in `requires`, so nothing else in the workflow changes. Validate the file afterwards (`circleci config validate` and/or a YAML parse with aliases enabled).

## Files to Change
- `.circleci/config.yml` — remove the `release-heroku` job.
