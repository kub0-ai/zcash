FROM debian:bookworm-slim AS base

ARG UID=2001
ARG GID=2001
ARG VERSION

LABEL org.opencontainers.image.source="https://github.com/kub0-ai/zcash"
LABEL org.opencontainers.image.description="Zcash v${VERSION}"
LABEL org.opencontainers.image.licenses="MIT"

RUN groupadd --gid ${GID} zcash \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} zcash \
  && apt-get update -y \
  && apt-get install -y curl gnupg gosu ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── amd64: install from official apt repo ────────────────────────────────
FROM base AS build-amd64
ARG VERSION
RUN set -ex \
  && echo "deb [signed-by=/usr/share/keyrings/zcash.gpg] https://apt.z.cash/ bookworm main" \
     > /etc/apt/sources.list.d/zcash.list \
  && curl -sL https://apt.z.cash/zcash.asc | gpg --dearmor -o /usr/share/keyrings/zcash.gpg \
  && apt-get update -y \
  && apt-get install -y zcash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# ── arm64: compile from source ───────────────────────────────────────────
FROM base AS build-arm64
ARG VERSION
RUN set -ex \
  && apt-get update -y \
  && apt-get install -y \
     build-essential pkg-config libc6-dev m4 autoconf libtool \
     ncurses-dev unzip git python3 zlib1g-dev bsdmainutils automake \
     libtinfo-dev wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN set -ex \
  && git clone --depth 1 --branch "v${VERSION}" https://github.com/zcash/zcash.git /tmp/zcash \
  && cd /tmp/zcash \
  && ./zcutil/build.sh -j$(nproc) \
  && install -m 755 src/zcashd src/zcash-cli src/zcash-tx /usr/local/bin/ \
  && cd / && rm -rf /tmp/zcash

# ── final stage: pick the right build ────────────────────────────────────
ARG TARGETARCH
FROM build-${TARGETARCH} AS final
ARG VERSION

ENV ZCASH_VERSION=${VERSION}
ENV ZCASH_DATA=/srv/zcashd/.zcash

# Download Zcash params (Sprout + Sapling proving/verifying keys, ~760MB)
# These are architecture-independent and required for zcashd to start.
RUN mkdir -p /srv/zcashd/.zcash-params \
  && for f in sprout-proving.key sprout-verifying.key \
              sapling-spend.params sapling-output.params; do \
       echo "Fetching $f..." \
       && curl -sL "https://download.z.cash/downloads/$f" \
          -o "/srv/zcashd/.zcash-params/$f"; \
     done \
  && chown -R zcash:zcash /srv/zcashd

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/srv/zcashd/.zcash"]
EXPOSE 8232 8233

ENTRYPOINT ["/entrypoint.sh"]
CMD ["zcashd"]
