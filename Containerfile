# This Containerfile serves both :latest and :pkg tags
# (io.daemonless.pkg-source="containerfile" tells build.sh to use this file for :pkg)
# Since transmission is installed via pkg, both tags produce identical images.

ARG BASE_VERSION=15
FROM ghcr.io/daemonless/base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG PACKAGES="transmission-daemon transmission-web ca_root_nss"
LABEL org.opencontainers.image.title="transmission" \
    org.opencontainers.image.description="Transmission BitTorrent client on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/transmission" \
    org.opencontainers.image.url="https://transmissionbt.com/" \
    org.opencontainers.image.documentation="https://github.com/transmission/transmission" \
    org.opencontainers.image.licenses="GPL-2.0-or-later" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="9091" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.volumes="/downloads,/watch" \
    io.daemonless.pkg-source="containerfile" \
    io.daemonless.category="Downloaders" \
    io.daemonless.upstream-mode="pkg" \
    io.daemonless.upstream-package="transmission-daemon" \
    io.daemonless.packages="${PACKAGES}"

# Install transmission daemon and web interface
RUN pkg update && \
    pkg install -y \
    ${PACKAGES} && \
    mkdir -p /app && pkg info transmission-daemon | sed -n 's/.*Version.*: *//p' > /app/version && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/*

# Create directories (transmission user/group created by package)
RUN mkdir -p /config /downloads /watch && \
    chown -R bsd:bsd /config /downloads /watch

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/transmission/run /etc/cont-init.d/* 2>/dev/null || true

# Set up s6 service link

EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch


