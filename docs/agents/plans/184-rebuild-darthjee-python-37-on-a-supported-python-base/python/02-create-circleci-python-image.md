# Create circleci_python/0.1.0
Create the new `darthjee/circleci_python` CircleCI image on `cimg/python:3.12` (the same base as `circleci_django`), replacing the legacy `circleci/python:3.7.2` base.

`Dockerfile`, following the `circleci_django/0.1.0` base-stage pattern:

```dockerfile
FROM cimg/python:3.12

USER root

RUN mkdir -p /home/circleci/project; \
    chown circleci:circleci -R /home/circleci/project

USER circleci
WORKDIR /home/circleci/project

RUN pip install --no-cache-dir pipenv
```

If `cimg/python:3.12` already ships `pipenv`, drop the `pip install` line and list `pipenv` in the README as provided by the base.

`README.md`: follow `docs/agents/image-readme.md`, using `circleci_python_37/0.2.2/README.md` as a template. Use the title `darthjee/circleci_python` and describe it as the CircleCI counterpart of `darthjee/python` (parallel, not built on top of it). Drop the legacy note, keep the executor and `FROM` usage examples with `<version>` placeholders, and keep the `circleci` user / virtualenv sentence.

Verify with `bin/script.sh pre_build circleci_python`, `bin/script.sh build circleci_python`, `bin/script.sh test circleci_python`, and `docker run --rm darthjee/circleci_python:0.1.0 pipenv --version`.

## Files to Change
- `circleci_python/0.1.0/Dockerfile` — new CircleCI image on `cimg/python:3.12` with `pipenv`
- `circleci_python/0.1.0/README.md` — Docker Hub description for `darthjee/circleci_python`
