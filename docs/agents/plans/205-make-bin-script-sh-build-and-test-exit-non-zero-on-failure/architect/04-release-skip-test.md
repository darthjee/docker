# Exclude test/ from the release skip check

In `push()`, call `skip_if_unchanged "$image" ":(exclude)$image/$version/README.md" ":(exclude)$image/$version/test/"`. Update the "excluding README.md" message in `skip_if_unchanged` so it doesn't name only README (e.g. "excluding README.md and test/", or list the excluded pathspecs). Leave `description()` as is: it already re-pushes descriptions on any change and that's harmless.

## Files to Change
- `bin/image.sh` — `push()` passes the extra exclude; skip message updated
