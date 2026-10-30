# Let skip_if_unchanged exclude README.md for the image push

A README-only commit must not rebuild and re-push an image under the same version tag, while the description step (step 03) still needs the full-folder check.

Make `skip_if_unchanged` in `bin/image.sh` accept optional extra git pathspecs after the image name and pass them to `git diff` after `-- "$image/$version/"`. Keep the current output and the `exit 0` behaviour.

- In `push()`, call `skip_if_unchanged "$image" ":(exclude)$image/$version/README.md"`, so the image is only pushed when something other than its README changed.
- Called without extra pathspecs (step 03), it keeps diffing the whole folder.
- Make the skip message say what was ignored, e.g. `No changes in $image/$version/ (excluding README.md) since $prev_tag, skipping.`, so the CI log is clear.

## Files to Change

- `bin/image.sh` — `skip_if_unchanged` takes optional pathspecs; `push()` excludes `README.md`.
