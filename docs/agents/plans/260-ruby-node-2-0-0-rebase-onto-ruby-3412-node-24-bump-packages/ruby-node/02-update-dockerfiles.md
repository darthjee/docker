# Delete home/ and rewrite the Dockerfiles
Delete the `home/` folder (the unused `Gemfile`) from all three `2.0.0` folders.

Rewrite each Dockerfile. `ruby_node/2.0.0/Dockerfile`:

```dockerfile
FROM darthjee/ruby_3412:1.0.0

USER root

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs ncat && \
    rm -rf /var/lib/apt/lists/*

USER app
```

- `circleci_ruby_node/2.0.0/Dockerfile`: same, `FROM darthjee/circleci_ruby_3412:1.0.0`, final `USER circleci`.
- `production_ruby_node/2.0.0/Dockerfile`: same, `FROM darthjee/production_ruby_3412:1.0.0`, final `USER app`.

No separate `apt-get update` (the nodesource setup script runs it); `&&` everywhere so any failure fails the build.

## Files to Change
- `ruby_node/2.0.0/Dockerfile`, `circleci_ruby_node/2.0.0/Dockerfile`, `production_ruby_node/2.0.0/Dockerfile`
- `ruby_node/2.0.0/home/`, `circleci_ruby_node/2.0.0/home/`, `production_ruby_node/2.0.0/home/` — deleted
