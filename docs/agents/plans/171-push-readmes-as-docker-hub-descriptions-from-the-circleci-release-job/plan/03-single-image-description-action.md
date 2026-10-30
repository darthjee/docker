# Add a single-image description action

The release job needs to push exactly one image's description, without the `circleci_`/`production_` fan-out of `push_description_images`.

Add a `description` action to `bin/image.sh`, next to `build`/`tag`/`push`/`test`:

```bash
bin/image.sh description <image>
```

- `bin/image.sh` sources `bin/docker_login.sh` and `bin/push_description.sh` (paths relative to the repo root, as `bin/script.sh` does).
- The new `description()` function:
  1. calls `skip_if_unchanged "$image"` with no extra pathspec, so it runs only when `<image>/<version>/`, README included, changed since the previous tag;
  2. calls `push_description_image "$image"`, which handles the missing-README warning, the login and the HTTP check from step 02.
- Add `description` to the usage/`Actions:` text.
- Leave `bin/script.sh push_description <images>` and `push_description_images` unchanged.

## Files to Change

- `bin/image.sh` — source the description helpers; add `description()` and its `case` entry and usage line.
