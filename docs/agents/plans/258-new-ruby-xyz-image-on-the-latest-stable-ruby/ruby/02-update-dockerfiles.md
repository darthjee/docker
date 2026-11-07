# Update the Dockerfiles
In each of the three new Dockerfiles:

1. `FROM darthjee/scripts:0.11.0 as scripts` → `FROM darthjee/scripts:0.15.0 AS scripts`.
2. Base image: `ruby:3.3.1` → `ruby:3.4.12` (dev, production), and `cimg/ruby:3.3.1` → `cimg/ruby:3.4.12` (circleci).
3. Bundler: install the same latest Bundler release in all three (look it up with `gem search -r '^bundler$'`). Dev/production keep `gem update --system` followed by `gem install bundler:<v> --default`. Circleci replaces `bundler:2.6.8` with `bundler:<v>`.
4. Circleci only: remove the `curl -L https://codeclimate.com/downloads/test-reporter/... > /usr/local/bin/cc-test-reporter && chmod +x ...;` part of the `RUN`, and keep the rest of that `RUN` chain working.
5. Modernise the syntax, with no change in behaviour:
   - `as` → `AS` in every `FROM … as <stage>`;
   - `ENV HOME_DIR /home/app` → `ENV HOME_DIR=/home/app` (same for `BUNDLE_FOLDER`);
   - `chown app.app` → `chown app:app`, and `circleci.circleci` → `circleci:circleci`.

Keep everything else, including the stage layout, the `bundle_builder.sh` flow and the `COPY --from=scripts` lines. `production_` keeps `bundle config set without 'development test'`.

## Files to Change
- `ruby_3412/1.0.0/Dockerfile` — scripts 0.15.0, `ruby:3.4.12`, Bundler, syntax.
- `circleci_ruby_3412/1.0.0/Dockerfile` — scripts 0.15.0, `cimg/ruby:3.4.12`, Bundler, `cc-test-reporter` removed, syntax.
- `production_ruby_3412/1.0.0/Dockerfile` — scripts 0.15.0, `ruby:3.4.12`, Bundler, syntax.
