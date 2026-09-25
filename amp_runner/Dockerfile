# Debian, not Alpine: Amp ships only glibc binaries.
ARG BUILD_FROM=ghcr.io/home-assistant/base-debian:trixie
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG TARGETARCH
ARG AMP_VERSION=latest
ARG HA_CLI_VERSION=5.5.0

# Tools that Amp needs, plus tools that help it debug HAOS.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        curl \
        docker-cli \
        findutils \
        git \
        jq \
        nodejs \
        npm \
        openssh-client \
        ripgrep \
        tmux \
        util-linux \
    && rm -rf /var/lib/apt/lists/*

# Amp CLI
RUN npm install -g "@sourcegraph/amp@${AMP_VERSION}" \
    && npm cache clean --force \
    && amp --version

# Home Assistant CLI (`ha`), which talks to the Supervisor with SUPERVISOR_TOKEN.
# The Supervisor passes BUILD_ARCH; a plain `docker buildx build` passes TARGETARCH.
RUN arch="${BUILD_ARCH:-}" \
    && if [ -z "${arch}" ]; then \
        case "${TARGETARCH}" in \
            amd64) arch=amd64 ;; \
            arm64) arch=aarch64 ;; \
            *) echo "Unsupported architecture: '${TARGETARCH}'" >&2 && exit 1 ;; \
        esac; \
    fi \
    && curl -fsSL -o /usr/bin/ha \
        "https://github.com/home-assistant/cli/releases/download/${HA_CLI_VERSION}/ha_${arch}" \
    && chmod a+x /usr/bin/ha \
    && ha --help > /dev/null

COPY rootfs /

RUN chmod a+x \
        /etc/s6-overlay/s6-rc.d/amp/run \
        /etc/s6-overlay/s6-rc.d/amp/finish
