FROM darthjee/production_ruby_3412:1.0.0

USER root

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs ncat && \
    rm -rf /var/lib/apt/lists/*

USER app
