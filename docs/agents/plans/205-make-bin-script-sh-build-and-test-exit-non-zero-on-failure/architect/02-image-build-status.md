# Check docker build in bin/image.sh build

In `build()`, `docker build ... || return 1` so a failed build doesn't go on to tag `latest` as the version. Also make the top-level `case` exit non-zero on failure for `build`/`tag` (e.g. `"build") build "$IMAGE_NAME" "$ARCH" || exit 1 ;;`), like `test` already does.

## Files to Change
- `bin/image.sh` — `build()` returns non-zero on `docker build` failure; `build`/`tag` actions exit non-zero
