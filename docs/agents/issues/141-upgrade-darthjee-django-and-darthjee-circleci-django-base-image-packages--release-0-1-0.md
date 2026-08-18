# Issue: Upgrade darthjee/django and darthjee/circleci_django base image packages (release 0.1.0)

## Description

`darthjee/majora` builds its `majora-base` images `FROM darthjee/django:0.0.2` / `FROM darthjee/circleci_django:0.0.2` (`dockerfiles/majora-base/Dockerfile`, `dockerfiles/production_majora-base/Dockerfile`, `dockerfiles/circleci_majora-base/Dockerfile`). As part of darthjee/majora#1157 (bumping `gunicorn` to `^23.0` to patch CVE-2024-1135/CVE-2024-6827, plus an audit of the rest of the backend's Poetry dependencies), the `darthjee/django` and `darthjee/circleci_django` base images were also inspected and found to be carrying outdated/vulnerable OS packages of their own. `darthjee/production_django` shares the same `python:3.12-slim-bullseye` base and unpinned `poetry` install and is affected the same way, so it's included in this release too.

This issue requests a `0.1.0` release of `darthjee/django`, `darthjee/circleci_django`, and `darthjee/production_django` (see Solution) so `darthjee/majora` can move its `FROM` tags from `0.0.2` to `0.1.0`, tracked in darthjee/majora#1157.

## Problem

### `darthjee/django:0.0.2` (`django/0.0.2/Dockerfile`)

Inspected via:
```bash
docker run --rm darthjee/django:0.0.2 python --version   # Python 3.12.11
docker run --rm darthjee/django:0.0.2 poetry --version    # Poetry 2.2.1
docker run --rm darthjee/django:0.0.2 cat /etc/os-release # Debian 11 (bullseye)
docker run --rm --user root darthjee/django:0.0.2 sh -c "apt-get update -qq; apt list --upgradable"
```

- **`FROM python:3.12-slim-bullseye`**: Debian 11 "bullseye" is now `oldoldstable`; its packages are only getting `oldoldstable-security` patches (LTS-tier, not full security support), and `apt list --upgradable` inside the image already shows it behind even on that reduced feed:
  - `libssl1.1` 1.1.1w-0+deb11u4 → 1.1.1w-0+deb11u8
  - `openssl` 1.1.1w-0+deb11u3 → 1.1.1w-0+deb11u8
  - `libc6`/`libc-bin`/`libc6-dev` 2.31-13+deb11u13 → 2.31-13+deb11u14
  - `libgnutls30` 3.7.1-5+deb11u7 → 3.7.1-5+deb11u10
  - `curl`/`libcurl4` 7.74.0-1.3+deb11u15 → 7.74.0-1.3+deb11u16
  - `libkrb5-3`/`libgssapi-krb5-2`/`libk5crypto3` 1.18.3-6+deb11u7 → 1.18.3-6+deb11u8
  - `libpam0g`/`libpam-modules`/`libpam-modules-bin`/`libpam-runtime` 1.4.0-9+deb11u1 → 1.4.0-9+deb11u2
  - `dpkg`/`dpkg-dev`/`libdpkg-perl` 1.20.13 → 1.20.14
  - `ca-certificates` 20210119 → 20250419~deb12u1~deb11u1
  - `tzdata` 2025b-0+deb11u1 → 2026b-0+deb11u1
  - (plus `libssl-dev`, `linux-libc-dev`, `libsystemd0`, `libudev1`, `liblzma5`, `libnghttp2-14`, `xz-utils`, `perl`/`perl-base`/`perl-modules-5.32` at similar minor-patch deltas)

  Moving off `bullseye` fixes all of the above at once and gets back onto a fully-supported Debian release; a rebuild pinned to a current Debian release will pull current patched versions of each package automatically.

- **`poetry`** — installed via unpinned `pip install --no-cache-dir poetry` (`django/0.0.2/Dockerfile` line 19), currently resolving to `2.2.1`. It floats to whatever's newest on rebuild day instead of being reproducible.

### `darthjee/production_django:0.0.2` (`production_django/0.0.2/Dockerfile`)

Shares the exact same `FROM python:3.12-slim-bullseye` base and unpinned `pip install --no-cache-dir poetry` install as `django:0.0.2` — per this repo's image hierarchy, production images are meant to share the same base image as their development counterpart, so this image is affected by the same package/reproducibility issues described above and is in scope for this release.

### `darthjee/circleci_django:0.0.2` (`circleci_django/0.0.2/Dockerfile`)

Built `FROM cimg/python:3.12` (CircleCI's convenience image, itself Ubuntu 22.04 "jammy"-based). `apt list --upgradable` inside the current image shows the snapshot is stale across the board — notably:

  - `docker-ce`/`docker-ce-cli`/`docker-ce-rootless-extras` 25.0.3 → 29.7.2
  - `docker-buildx-plugin` 0.12.1 → 0.36.1
  - `docker-compose-plugin` 2.24.6 → 5.5.0
  - `git`/`git-man` 2.51.0 → 2.55.0, `git-lfs` 3.4.1 → 3.7.1
  - `openssl`/`libssl3`/`libssl-dev` 3.0.2-0ubuntu1.15/.20 → 3.0.2-0ubuntu1.26
  - `libcurl4`/`libcurl4-openssl-dev`/`curl` 7.81.0-1ubuntu1.21 → 7.81.0-1ubuntu1.25
  - `libc6`/`libc-bin`/`libc6-dev` 2.35-0ubuntu3.6 → 2.35-0ubuntu3.14
  - `libmysqlclient21`/`libmysqlclient-dev`/`mysql-client-8.0` 8.0.44 → 8.0.46
  - `libpq5`/`libpq-dev`/`postgresql-client-14` 14.11 → 14.23
  - `python3.10`/`libpython3.10*` 3.10.12-1~22.04.3 → 3.10.12-1~22.04.16
  - `openssh-client` 8.9p1-3ubuntu0.6 → 8.9p1-3ubuntu0.16
  - `sudo` 1.9.9-1ubuntu2.4 → 1.9.9-1ubuntu2.6
  - `tzdata` 2023d → 2026c

  Since `cimg/python:3.12` is already an unpinned/floating tag rather than a hard-pinned digest, no `Dockerfile` line needs to change here — a plain rebuild against the current `cimg/python:3.12` tag pulls a fresh `jammy-updates`/`jammy-security` snapshot and resolves all of the above. Flagging it so the rebuild happens as part of this release rather than assuming the existing `0.0.2` layer is still current.

## Solution

- [ ] Rebuild `darthjee/django` off `python:3.12-slim-bookworm`, with `poetry` pinned to `2.2.1`, and publish as `darthjee/django:0.1.0`.
- [ ] Rebuild `darthjee/production_django` off `python:3.12-slim-bookworm`, with `poetry` pinned to `2.2.1`, and publish as `darthjee/production_django:0.1.0`.
- [ ] Rebuild `darthjee/circleci_django` off a current `cimg/python:3.12` pull, and publish as `darthjee/circleci_django:0.1.0`.

Once all three are published, `darthjee/majora` will bump its `dockerfiles/*-base/Dockerfile` `FROM` tags from `0.0.2` to `0.1.0` (tracked in darthjee/majora#1157).

## Benefits

- Closes the outdated/vulnerable OS package gap in `darthjee/django`, `darthjee/production_django`, and `darthjee/circleci_django`.
- Moves `darthjee/django`/`darthjee/production_django` off Debian `oldoldstable` (bullseye) onto Debian 12 (bookworm), a fully-supported release.
- Makes the `poetry` install reproducible (pinned to `2.2.1`) instead of floating to whatever version is newest on rebuild day.
- Unblocks `darthjee/majora`#1157 from bumping its base image `FROM` tags to a patched, up-to-date `0.1.0`.
