FROM darthjee/node:0.2.2

USER root

ARG MONGODB_SERIES=8.0
ARG MONGODB_TOOLS_VERSION=100.20.0

# mongosh comes from MongoDB's Debian apt repo (amd64 + arm64).
# MongoDB's Debian repo does not ship mongodb-database-tools for arm64 and
# there is no debian12 arm64 .deb, so the tools are installed from the
# per-arch .deb downloads: debian12 on amd64, ubuntu2204 on arm64.
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg curl ca-certificates && \
    . /etc/os-release && \
    curl -fsSL "https://www.mongodb.org/static/pgp/server-${MONGODB_SERIES}.asc" | \
      gpg --dearmor -o "/usr/share/keyrings/mongodb-server-${MONGODB_SERIES}.gpg" && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${MONGODB_SERIES}.gpg ] https://repo.mongodb.org/apt/debian ${VERSION_CODENAME}/mongodb-org/${MONGODB_SERIES} main" \
      > "/etc/apt/sources.list.d/mongodb-org-${MONGODB_SERIES}.list" && \
    case "$(dpkg --print-architecture)" in \
      amd64) TOOLS_PLATFORM=debian12-x86_64 ;; \
      arm64) TOOLS_PLATFORM=ubuntu2204-arm64 ;; \
      *) echo "unsupported architecture: $(dpkg --print-architecture)" >&2; exit 1 ;; \
    esac && \
    curl -fsSL -o /tmp/mongodb-database-tools.deb \
      "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-${TOOLS_PLATFORM}-${MONGODB_TOOLS_VERSION}.deb" && \
    apt-get update && \
    apt-get install -y --no-install-recommends mongodb-mongosh /tmp/mongodb-database-tools.deb && \
    rm -f /tmp/mongodb-database-tools.deb && \
    rm -rf /var/lib/apt/lists/*

USER node
