# Rewrite the Dockerfile
In `circleci_node/0.2.3/Dockerfile`:

- **base**: keep `USER root` for the `mkdir`/`chown`, then add `USER circleci` at the end of the stage. That way both the final image and anything built `FROM` it run as `circleci`.
- **builder**:
  - start with `USER root` (yarn must run as root, because `yarn_builder.sh` reads `/usr/local/share/.cache/yarn/v6`);
  - `COPY --chown=circleci:circleci` the `home/*` files and `yarn_builder.sh` (instead of `ADD` without ownership and `--chown=node:node`);
  - set `ENV HOME_DIR /home/circleci` and `ENV APP_DIR /home/circleci/project`;
  - drop the stray `USER node`.
- **final** (`FROM base`, already `circleci`): `COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /home/circleci/.cache/yarn/v6/`. Do not set `YARN_CACHE_FOLDER`.

Sketch:

```dockerfile
FROM darthjee/scripts:<v> as scripts
FROM cimg/node:22.14.0 as base

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci /home/circleci -R;

WORKDIR /home/circleci/project

USER circleci

######################################

FROM base as builder

USER root

COPY --chown=circleci:circleci home/* /home/circleci/project/
ENV HOME_DIR /home/circleci
ENV APP_DIR /home/circleci/project

COPY --chown=circleci:circleci --from=scripts /home/scripts/builder/yarn_builder.sh /usr/local/sbin/yarn_builder.sh
RUN /bin/bash yarn_builder.sh

#######################
#FINAL IMAGE
FROM base

COPY --chown=circleci:circleci --from=builder /home/circleci/yarn/new/ /home/circleci/.cache/yarn/v6/
```

Make sure the parent `/home/circleci/.cache` (and `.cache/yarn`) ends up owned by `circleci`. Docker `COPY --chown` only chowns the copied content, not directories it creates along the way. If they come out root-owned, create them in `base` (`mkdir -p /home/circleci/.cache/yarn` before the `chown -R`).

## Files to Change
- `circleci_node/0.2.3/Dockerfile` — runtime user `circleci`, new cache destination, builder ownership/`APP_DIR` cleanup
