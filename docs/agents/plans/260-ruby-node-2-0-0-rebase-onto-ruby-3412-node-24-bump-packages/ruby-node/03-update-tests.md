# Update the subtests
In all three `2.0.0/test/subtests/` (keep `test/Dockerfile`, `test/test.sh`, `test/test.js` as copied — the image has no `home/`, so its own `test/Dockerfile` is still needed):

- `node.sh`:

  ```bash
  #!/bin/bash
  set -e
  node --version | grep -q '^v24\.' || { echo "expected Node 24, got $(node --version)"; exit 1; }
  node /home/test/test.js
  ```

- `bundler.sh`:

  ```bash
  #!/bin/bash
  set -e
  ruby --version | grep -q '^ruby 3\.4\.' || { echo "expected Ruby 3.4, got $(ruby --version)"; exit 1; }
  gem --version && bundle --version
  ```

- `tools.sh` (new):

  ```bash
  #!/bin/bash
  set -e
  npm --version
  ncat --version
  ```

## Files to Change
- `{,circleci_,production_}ruby_node/2.0.0/test/subtests/node.sh`
- `{,circleci_,production_}ruby_node/2.0.0/test/subtests/bundler.sh`
- `{,circleci_,production_}ruby_node/2.0.0/test/subtests/tools.sh` — new
