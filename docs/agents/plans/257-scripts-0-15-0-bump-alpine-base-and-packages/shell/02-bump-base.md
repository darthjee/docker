# Bump the Alpine base and add bash
In `scripts/0.15.0/Dockerfile`, replace `FROM alpine:3.9.4 as base` with the latest stable Alpine pinned to its full patch version (`FROM alpine:3.x.y AS base`), and install bash with the existing tools: `RUN apk add --no-cache bash curl jq`. Then `scripts/0.15.0/test/Dockerfile` no longer needs `RUN apk add --no-cache bash`; remove it.

## Files to Change
- `scripts/0.15.0/Dockerfile` — new base, add `bash`.
- `scripts/0.15.0/test/Dockerfile` — drop the redundant bash install.
