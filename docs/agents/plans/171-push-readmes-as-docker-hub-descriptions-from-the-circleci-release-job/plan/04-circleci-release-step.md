# Add the step to the CircleCI release job

In `.circleci/config.yml`, add a `run` step to the `release` job right after the `Release` step:

```yaml
      - run:
          name: Push description
          command: bin/image.sh description << parameters.image >>
```

- It runs in its own step, so the image push's `skip_if_unchanged` `exit 0` does not affect it.
- It reuses the `DOCKER_HUB_USERNAME`/`DOCKER_HUB_PASSWORD` project variables the job already has.
- Leave the workflow's job list and `requires` chain unchanged.

## Files to Change

- `.circleci/config.yml` — new `Push description` step in the `release` job.
