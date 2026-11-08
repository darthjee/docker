FROM darthjee/circleci_node:0.3.0

USER root

ARG MONGODB_SERIES=9.0
ARG MONGOSH_VERSION=2.14.1
ARG MONGODB_TOOLS_VERSION=100.20.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg curl ca-certificates && \
    . /etc/os-release && \
    curl -fsSL "https://www.mongodb.org/static/pgp/server-${MONGODB_SERIES}.asc" | \
      gpg --dearmor -o "/usr/share/keyrings/mongodb-server-${MONGODB_SERIES}.gpg" && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${MONGODB_SERIES}.gpg ] https://repo.mongodb.org/apt/ubuntu ${VERSION_CODENAME}/mongodb-org/${MONGODB_SERIES} multiverse" \
      > "/etc/apt/sources.list.d/mongodb-org-${MONGODB_SERIES}.list" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      "mongodb-mongosh=${MONGOSH_VERSION}" \
      "mongodb-database-tools=${MONGODB_TOOLS_VERSION}" && \
    rm -rf /var/lib/apt/lists/*

USER circleci
