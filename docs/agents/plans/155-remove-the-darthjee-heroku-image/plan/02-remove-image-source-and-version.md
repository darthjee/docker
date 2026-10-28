# Remove the image source, version entry and README entry

- `git rm -r heroku/` — removes `heroku/0.0.1/Dockerfile`, `home/scripts/{entrypoint,login}.sh` and the `script/` host wrapper (`script/heroku`, `script/lib/install.sh`).
- `version`: remove the `heroku=0.0.1` line.
- `README.md`: under `#### Tools`, remove the `  - [heroku:0.0.1](https://hub.docker.com/repository/docker/darthjee/heroku)` line (keep `scripts`). Leave the "maximum layer limit (40 for Heroku)" note — it is about the Heroku platform, not this image.

## Files to Change
- `heroku/` — delete the whole folder.
- `version` — drop `heroku=0.0.1`.
- `README.md` — drop the `heroku:0.0.1` image entry.
