# Implement KEEP_OLD=<n> in release
In `scripts/0.14.0/home/sbin/deploy_frontend.sh`, `run_release`:

1. **Validate locally, before `remote`** (like `CLEANUP_MAX_AGE_MINUTES` in `run_cleanup`): classify `KEEP_OLD` as `none` (unset, empty, `false`, `0`), `all` (`true`) or a count (`[0-9]+` and > 0; leading zeros like `03` are fine, but normalise with `$((10#...))` or strip them so the shell arithmetic is not read as octal). Anything else: `echo "KEEP_OLD must be true, false or a number of folders to keep" >&2; return 1`, with no ssh call.
2. **Build the chain:**
   - `none`: same as today (append `&& rm -rf $old`).
   - `all`: same as today (nothing appended).
   - count `n`: append `&& <prune>` where `<prune>` is a POSIX sh snippet run in the live folder's parent. Suggested shape (with `parent`=`dirname` and `base`=`basename` of `${SSH_REMOTE_DIR%/}`, both passed through `quote`):

     ```sh
     cd <parent> && for d in <base>_old_*; do
       ts=${d#<base>_old_}
       case $ts in ''|*[!0-9]*) continue ;; esac
       [ -d "$d" ] && echo "$ts"
     done | sort -rn | tail -n +<n+1> | while read -r ts; do
       rm -rf <base>_old_"$ts" && echo "Removed old folder: <parent>/<base>_old_$ts"
     done
     ```

     Quoting notes: in `for d in '<base>'_old_*` only the `*` is a glob, so a `*`, `?` or `[` in the basename stays literal. Inside `${d#...}`, the quoted base is also matched literally. If the glob matches nothing, `d` is the literal pattern, and its suffix `*` fails the digits check, so the loop does nothing. Make sure a failing `rm` makes the whole step fail (e.g. `|| exit 1` inside the loop, or check the pipeline status in a form that works in ash). An empty prune list must exit 0.
   - Keep the existing steps 1–3 of the chain byte-identical, so the 0.13.0 command-string tests for `false`/`true` still pass unchanged.
3. Update the header comment of `run_release` to describe the three modes.

## Files to Change
- `scripts/0.14.0/home/sbin/deploy_frontend.sh` — `KEEP_OLD` validation and the prune step in `run_release`
