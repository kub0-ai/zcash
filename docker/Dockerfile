FROM debian:bookworm-slim AS base

ARG UID=2001
ARG GID=2001
ARG VERSION

LABEL org.opencontainers.image.source="https://github.com/kub0-ai/zcash"
LABEL org.opencontainers.image.description="ARCHIVAL zcashd v${VERSION} — EOL / do not deploy mainnet (EOS halt 3417100 / 2026-07-18). Prefer Zebra/Zallet."
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.deprecated="true"

RUN groupadd --gid ${GID} zcash \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} zcash \
  && apt-get update -y \
  && apt-get install -y curl gnupg gosu ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── amd64: install from official apt repo (fingerprint-pinned) ───────────
FROM base AS build-amd64
ARG VERSION
# Space-separated 40-hex fingerprints of keys expected in https://apt.z.cash/zcash.asc
# Defaults match KEYS in repo root (ZODL + ECC). Override via --build-arg APT_KEY_FPRS=...
ARG APT_KEY_FPRS="033834DD49DECF9DBB9934BC6C93CA8E58E26AB1 B1C9095EAA1848DBB54D9DDA1D05FDC66B372CFE"
RUN set -ex \
  && echo "deb [signed-by=/usr/share/keyrings/zcash.gpg] https://apt.z.cash/ bookworm main" \
     > /etc/apt/sources.list.d/zcash.list \
  && curl -sL https://apt.z.cash/zcash.asc -o /tmp/zcash.asc \
  && gpg --show-keys --with-colons /tmp/zcash.asc > /tmp/zcash.asc.colons \
  && for fpr in ${APT_KEY_FPRS}; do \
       fpr_u=$(echo "$fpr" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]'); \
       if ! grep -q "^fpr:::::::::${fpr_u}:$" /tmp/zcash.asc.colons; then \
         echo "ERROR: apt.z.cash key fingerprint not present: ${fpr_u}"; \
         echo "--- keys in zcash.asc ---"; gpg --show-keys --with-fingerprint /tmp/zcash.asc; \
         exit 1; \
       fi; \
       echo "OK fingerprint ${fpr_u}"; \
     done \
  && gpg --dearmor -o /usr/share/keyrings/zcash.gpg /tmp/zcash.asc \
  && rm -f /tmp/zcash.asc /tmp/zcash.asc.colons \
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

# Params intentionally NOT downloaded.
# zcashd 6.20.0 is past EOS halt; baking ~760MB of curl'd (previously unhashed)
# Sprout/Sapling params into a non-deployable image was waste + supply-chain risk
# (ZCASH-PKG-03). Operators on supported stacks fetch params via Zebra/Zallet tooling.

RUN mkdir -p /srv/zcashd/.zcash-params \
  && chown -R zcash:zcash /srv/zcashd \
  && printf '%s\n' \
       'ARCHIVAL IMAGE — zcashd EOL / do not deploy mainnet' \
       "VERSION=${VERSION}" \
       'EOS halt height 3417100 (2026-07-18). Prefer Zebra + Zallet.' \
       > /srv/zcashd/EOL.txt \
  && chown zcash:zcash /srv/zcashd/EOL.txt

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/srv/zcashd/.zcash"]
EXPOSE 8232 8233

ENTRYPOINT ["/entrypoint.sh"]
CMD ["zcashd"]
