# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NODE_ENV=production

# 1. Install base system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    openssh-client \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js (20.x LTS) and npm
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Antigravity CLI binary
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- -d /usr/local/bin \
    && chmod +x /usr/local/bin/agy 2>/dev/null || true

# 4. Install OpenSpec CLI globally and pre-generate template structure
RUN npm install -g @fission-ai/openspec@latest \
    && mkdir -p /opt/openspec-template \
    && (cd /opt/openspec-template && OPENSPEC_TELEMETRY=0 openspec init --tools antigravity)

# 5. Dynamic unprivileged sandbox user creation (safe across Linux and macOS host GIDs)
ARG UID=1000
ARG GID=1000

RUN if ! getent group "${GID}" >/dev/null 2>&1; then \
        groupadd -g "${GID}" sandboxuser; \
    fi && \
    EXISTING_GROUP=$(getent group "${GID}" | cut -d: -f1) && \
    if ! getent passwd "${UID}" >/dev/null 2>&1; then \
        useradd -u "${UID}" -g "${EXISTING_GROUP}" -m -s /bin/bash sandboxuser; \
    else \
        EXISTING_USER=$(getent passwd "${UID}" | cut -d: -f1); \
        usermod -l sandboxuser "${EXISTING_USER}" 2>/dev/null || true; \
    fi

# Configure Git safe.directory globally to avoid dubious ownership errors on mounted volumes
RUN git config --system --add safe.directory /workspace \
    && git config --system --add safe.directory '*'

# Prepare workspace and user paths
WORKDIR /workspace
RUN mkdir -p /workspace /home/sandboxuser/.gemini \
    && chown -R ${UID}:${GID} /workspace /home/sandboxuser

# Install entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER ${UID}:${GID}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--dangerously-skip-permissions"]
