FROM darthjee/circleci_node:0.2.4

USER root

ARG MONGODB_SERIES=8.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg curl ca-certificates && \
    . /etc/os-release && \
    curl -fsSL "https://www.mongodb.org/static/pgp/server-${MONGODB_SERIES}.asc" | \
      gpg --dearmor -o "/usr/share/keyrings/mongodb-server-${MONGODB_SERIES}.gpg" && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${MONGODB_SERIES}.gpg ] https://repo.mongodb.org/apt/ubuntu ${VERSION_CODENAME}/mongodb-org/${MONGODB_SERIES} multiverse" \
      > "/etc/apt/sources.list.d/mongodb-org-${MONGODB_SERIES}.list" && \
    apt-get update && \
    apt-get install -y --no-install-recommends mongodb-mongosh mongodb-database-tools && \
    rm -rf /var/lib/apt/lists/*

USER circleci
