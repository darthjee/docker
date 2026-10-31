# Bump scripts in version
Set `scripts=0.12.0` under `# Tools` in the root `version` file so the `release-scripts` CircleCI job publishes `darthjee/scripts:0.12.0`. Do not change any downstream Dockerfile `FROM darthjee/scripts:0.11.0` lines; they are out of scope.

## Files to Change
- `version` — `scripts=0.11.0` → `scripts=0.12.0`.
