# Create scripts 0.13.0
Run `bin/script.sh init scripts 0.13.0`. Pass the version explicitly: with no version argument, `init` bumps the last segment, giving 0.12.1. This copies `scripts/0.12.0` to `scripts/0.13.0` and sets `scripts=0.13.0` in `version`. Commit this copy on its own, before any change.

## Files to Change
- `scripts/0.13.0/**` — new copy of 0.12.0
- `version` — `scripts=0.13.0`
