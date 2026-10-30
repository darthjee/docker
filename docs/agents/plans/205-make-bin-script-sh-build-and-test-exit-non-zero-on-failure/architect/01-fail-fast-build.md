# Fail fast in bin/build.sh

Make every function in `bin/build.sh` return non-zero on the first failure, and stop there.

- `fetch_bases`: for each `BASE`, try `docker pull "$BASE"`. If that fails, run `$0 build "$BUILDABLE" || return 1`, then check that the pinned tag exists with `docker image inspect "$BASE" >/dev/null 2>&1`. If it doesn't, print a clear error (e.g. `ERROR: $BASE not available: pull failed and building $BUILDABLE produced $BUILDABLE:<current version>, not the pinned tag`) and `return 1`.
- `build_image`: `fetch_bases "$IMAGE" || return 1`, then `bin/image.sh build "$IMAGE" || return 1`. Keep the "skipping" path returning 0.
- `build_images`: `build_image "$MOD$PROJECT" || return 1` inside the loop.
- `build`: `build_images "$PROJECT" || return 1` inside the loop.
- Remove the empty `current_version` stub only if nothing uses it (grep first).

## Files to Change
- `bin/build.sh` — propagate failures, fail fast, verify the pinned base after a fallback build
