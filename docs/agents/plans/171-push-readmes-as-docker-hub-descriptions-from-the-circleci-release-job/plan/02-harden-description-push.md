# Harden the description push

The description push must not block a release over a missing README, and must not hide Docker Hub errors.

- **`bin/push_description.sh`, `push_description_image`:**
  - On a missing `$IMAGE/$VERSION/README.md`, print `Warning: README not found at $README, skipping.` and `return 0` instead of `exit 1`. This also changes the manual family push: missing counterparts are now skipped instead of stopping the run.
  - Send the PATCH with `curl -sS -o <tmpfile> -w '%{http_code}'` (or an equivalent), and treat anything outside `2xx` as a failure. Print `Error: failed to push description for $REPO (HTTP <code>)` plus the response body, then `exit 1`. Print a short success line on `2xx`.
  - Keep the existing README-to-JSON escaping as it is.
- **`bin/docker_login.sh`, `docker_login`:** after fetching the token, fail with `Error: Docker Hub login failed` and `exit 1` when it is empty or `null`. Otherwise export it as today.

## Files to Change

- `bin/push_description.sh` — warn and skip on a missing README; fail on non-2xx.
- `bin/docker_login.sh` — fail when no token comes back.
