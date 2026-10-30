# Rewrite the Dockerfiles

Model each Dockerfile on the matching `taa` 1.5.0 Dockerfile, with the yarn step removed and an apt `gnuplot` layer added. Put `scripts` first, as `taa` does.

`taap/1.5.0/Dockerfile`:

```dockerfile
FROM darthjee/scripts:0.10.0 as scripts
FROM darthjee/taa:1.5.0 as base

######################################

FROM base as builder

COPY --chown=app:app home/* /home/app/app/
ENV HOME_DIR /home/app

COPY --chown=app:app --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

#######################
#FINAL IMAGE
FROM base

USER root
RUN apt-get update && apt-get install -y gnuplot && rm -rf /var/lib/apt/lists/*
USER app

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/
```

`production_taap/1.5.0/Dockerfile`: same as above, on `darthjee/production_taa:1.5.0`, with `RUN bundle config set without 'development test'` before `RUN /bin/bash bundle_builder.sh` (as in `production_taa/1.5.0`). No `--without` argument.

`circleci_taap/1.5.0/Dockerfile`: on `darthjee/circleci_taa:1.5.0`, copying `home/*` to `/home/circleci/project/`, with `ENV HOME_DIR /home/circleci` and `ENV BUNDLE_FOLDER /home/circleci/.rubygems`, and `--chown=circleci:circleci` throughout. The builder stage stays as `circleci` (no `USER app`). The final stage switches to `USER root` for apt, then back to `USER circleci`, and copies `/home/circleci/bundle/` into `/home/circleci/.rubygems/`.

Check the paths against `taa/1.5.0`, `circleci_taa/1.5.0` and `production_taa/1.5.0`. If `taa` does something differently (e.g. the user before `bundle_builder.sh`), follow `taa`.

## Files to Change
- `taap/1.5.0/Dockerfile` — rewritten as above
- `circleci_taap/1.5.0/Dockerfile` — rewritten, CircleCI user and paths
- `production_taap/1.5.0/Dockerfile` — rewritten, without development and test groups
