# Remove the image source and version entry

Delete the image folder and its version line:

- `git rm -r fly/` (only contains `fly/0.0.1/Dockerfile`).
- Remove the `fly=0.0.1` line under `# Tools` in `version`.
- Remove the `  - [fly:0.0.1](https://hub.docker.com/repository/docker/darthjee/fly)` entry under `#### Tools` in the root `README.md`.

## Files to Change
- `fly/0.0.1/Dockerfile` — deleted (whole `fly/` folder).
- `version` — drop `fly=0.0.1`.
- `README.md` — drop the `fly:0.0.1` image list entry.
