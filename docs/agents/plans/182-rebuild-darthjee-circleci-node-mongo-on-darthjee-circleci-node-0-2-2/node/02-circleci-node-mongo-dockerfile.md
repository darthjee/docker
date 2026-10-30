# Rebuild circleci_node_mongo Dockerfile
Rewrite `circleci_node_mongo/0.2.2/Dockerfile`:

- `FROM darthjee/circleci_node:0.2.2`
- `USER root`
- In one `RUN` layer:
  - install the prerequisites (`gnupg`, `curl`, `ca-certificates` if missing);
  - import MongoDB's server key into `/usr/share/keyrings/mongodb-server-<series>.gpg`;
  - add `deb [ arch=amd64,arm64 signed-by=... ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/<series> multiverse`;
  - `apt-get update && apt-get install -y mongodb-mongosh mongodb-database-tools`;
  - remove `/var/lib/apt/lists/*`.
  
  Derive the codename from `/etc/os-release` rather than hard-coding it if that stays simple.
- `USER circleci` at the end. This is an explicit decision, even though the base image ends as root.
- Keep `WORKDIR /home/circleci/project` (inherited from the base).

## Files to Change
- `circleci_node_mongo/0.2.2/Dockerfile` — new base, MongoDB repo, `mongosh` + database tools, `USER circleci`
