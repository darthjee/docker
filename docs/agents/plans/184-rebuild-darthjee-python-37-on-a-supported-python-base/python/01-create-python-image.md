# Create python/0.1.0
Create the new `darthjee/python` development image on a supported base, mirroring `python_37` but on `python:3.12-slim-bookworm`.

`Dockerfile`:

```dockerfile
FROM python:3.12-slim-bookworm

RUN useradd -u 1000 app; \
    mkdir -p /home/app/app; \
    chown app:app -R /home/app

WORKDIR /home/app/app

RUN pip install --no-cache-dir pipenv
USER app
```

`README.md`: follow `docs/agents/image-readme.md`, using `python_37/0.2.2/README.md` as a template. Use the title `darthjee/python`, base `python:3.12-slim-bookworm`, list `pipenv` under `## Tools`, keep the `app` user / working-directory and virtualenv sentences, and drop the legacy note. Use `<version>` placeholders instead of hardcoded tags. Mention that the slim base has no compiler toolchain.

Verify with `bin/script.sh pre_build python`, `bin/script.sh build python`, `bin/script.sh test python` (expected: `no tests for python`), and `docker run --rm darthjee/python:0.1.0 pipenv --version`.

## Files to Change
- `python/0.1.0/Dockerfile` — new image on `python:3.12-slim-bookworm` with `pipenv` and the `app` user
- `python/0.1.0/README.md` — Docker Hub description for `darthjee/python`
