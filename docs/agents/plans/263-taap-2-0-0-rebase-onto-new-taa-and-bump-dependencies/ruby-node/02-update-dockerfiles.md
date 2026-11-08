# Update the Dockerfiles
In each of the three `2.0.0/Dockerfile` files:
1. Use `FROM darthjee/scripts:0.15.0 AS scripts`.
2. Use `FROM darthjee/{,circleci_,production_}taa:2.0.0 AS base`.
3. Uppercase every `as`, giving `AS` (e.g. `FROM base AS builder`).
4. Rewrite `ENV K V` as `ENV K=V` (e.g. `ENV HOME_DIR=/home/app`).
5. Replace the gnuplot install line with:
   `RUN apt-get update && apt-get install -y --no-install-recommends gnuplot-nox && rm -rf /var/lib/apt/lists/*`
6. `production_taap` only: remove `RUN bundle config set without 'development test'`. `BUNDLE_WITHOUT=development:test` is inherited from `production_taa:2.0.0` (via production_rails_yarn), so the line is redundant. Before removing it, confirm that `docker run --rm darthjee/production_taa:2.0.0 printenv BUNDLE_WITHOUT` prints `development:test`.

Keep the rest of the structure unchanged: the builder stage runs `bundle_builder.sh`, and the final stage copies the bundle delta.

## Files to Change
- `taap/2.0.0/Dockerfile`
- `circleci_taap/2.0.0/Dockerfile`
- `production_taap/2.0.0/Dockerfile`
