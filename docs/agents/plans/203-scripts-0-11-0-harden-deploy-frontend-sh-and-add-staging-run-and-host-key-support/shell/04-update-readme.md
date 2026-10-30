# Update the README

Update `scripts/0.11.0/README.md` following `docs/agents/image-readme.md`: keep the existing
structure and add a `deploy_frontend.sh` section with:

- every action (`build`, `generate_key_file`, `generate_folder`, `copy_files`, `upload`, `link`,
  `run`, `release`) and what it does;
- every variable (required/optional, default): `SSH_PRIVATE_KEY`, `SSH_KNOWN_HOSTS`, `SSH_USER`,
  `SSH_HOST`, `SSH_PORT` (22), `SSH_REMOTE_DIR`, `SSH_REMOTE_TEMP_DIR`,
  `CIRCLE_WORKFLOW_WORKSPACE_ID`, `DEPLOY_PATH`, `SOURCE`, `TARGET`, `EXCLUDE_FROM`,
  `BUILD_COMMAND` (`npm run build`), `COMMAND` (caller quotes it), `KEEP_OLD` (`false`);
- tools the calling image must provide: `bash`, `ssh`, `rsync`, and `node`/`npm` for `build`;
- a CircleCI example of a full workflow, based on the Pidgey usage in the issue: parallel upload
  jobs into one staging tree, then `link`, `run`, and a final `release` job, plus the
  `COPY --from=darthjee/scripts:0.11.0 /home/scripts/sbin/deploy_frontend.sh /usr/local/sbin/` line;
- a note on how to run the tests (`bin/script.sh test scripts`).

## Files to Change
- `scripts/0.11.0/README.md` — `deploy_frontend.sh` documentation and example.
