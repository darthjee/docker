# Build and test on both arches
- `bin/script.sh test rails_gems` (amd64; covers `rails_gems` and `circleci_rails_gems`).
- `PLATFORM=linux/arm64 bin/script.sh test rails_gems`.
- `docker buildx build --platform linux/amd64,linux/arm64 -f rails_gems/3.0.0/Dockerfile rails_gems/3.0.0/` and the same for `circleci_rails_gems/3.0.0`, without `--push`.

All must pass; report any native-extension compile failure instead of working around it.

## Files to Change
- none (verification only)
