# Scope the production_ruby_331 1.1.1 bundler test
The production image installs gems without the `development` and `test` groups, but its `bundler.sh` checks every group. That makes it fail on `pry`, `simplecov`, `rubocop`, `rspec*` and the rest. Change the check to match the image, as `production_taap/1.5.0` does:

```bash
#!/bin/bash

BUNDLE_WITHOUT=development:test bundle check --gemfile=/home/app/app/Gemfile
```

This is a test-only change, so it stays on version 1.1.1 (no `version` bump). It still fails on 1.1.1 because of transitive drift, which step 02 fixes in the new version. Step 02's `init` copies this file into 1.1.2.

## Files to Change
- `production_ruby_331/1.1.1/test/subtests/bundler.sh` — prefix the check with `BUNDLE_WITHOUT=development:test`.
