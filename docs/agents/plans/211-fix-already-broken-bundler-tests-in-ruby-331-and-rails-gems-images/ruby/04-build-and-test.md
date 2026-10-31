# Build and test every image in scope
Build in dependency order and run the tests against the new versions:

```bash
bin/script.sh pre_build ruby_331 rails_gems
bin/script.sh build ruby_331
bin/script.sh build rails_gems
bin/script.sh test ruby_331 rails_gems
```

`bin/script.sh test ruby_331` covers `ruby_331`, `circleci_ruby_331` and `production_ruby_331`. `bin/script.sh test rails_gems` covers `rails_gems` and `circleci_rails_gems`. Both commands must exit 0. If a `bundle check` still reports missing gems, compare the lockfile in `home/` with what `bundle_builder.sh` installed. A mismatch usually means a bundler version difference rewrote the lock during the build.

## Files to Change
- None; this is a verification step. Fix any failure in the files from steps 01–03.
