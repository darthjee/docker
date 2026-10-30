# Update AGENTS.md
Apply the four `AGENTS.md` changes listed in the issue's *`AGENTS.md` changes* subsection, using its exact wording:

1. Version-folder list: replace the `README.md – (optional) ...` bullet with the "Every current image version should have one, written following [Image READMEs](docs/agents/image-readme.md)" bullet.
2. "Docker Hub Description Publishing": replace the opening "may include" paragraph with the three paragraphs describing `bin/script.sh push_description <image>` and `bin/push_description.sh` behavior, ending with "The lower-level `docker_hub.sh` script, provided by the `scripts` image, offers the same operations:"; keep the `docker_hub.sh` table and example unchanged.
3. Replace the closing note with: "> **Note:** Releases (`bin/image.sh push`, the CI `release` job) do not push descriptions; run `bin/script.sh push_description` separately." — no "yet", no issue link.
4. Documentation table: add `| [Image READMEs](docs/agents/image-readme.md) | Conventions for per-image `README.md` files published as Docker Hub descriptions. |`.

## Files to Change
- `AGENTS.md` — the four edits above.
