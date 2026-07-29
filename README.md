# kub0-ai/zcash — **EOL / do not deploy (mainnet)**

> ⛔ **This package is retired for live mainnet.**  
> Upstream `zcashd` **6.20.0** hit End-of-Support halt at height **3417100** (**2026-07-18**).  
> Unmodified nodes **refuse to run** on current mainnet. See **[DEPRECATION.md](./DEPRECATION.md)**.

**Do not** treat `ghcr.io/kub0-ai/zcash:latest` (or any tag from this repo) as a supported mainnet dependency.

## Migrate

| Role | Recommended project |
| --- | --- |
| Consensus / full node | [Zebra](https://github.com/ZcashFoundation/zebra) (`zebrad`) |
| Wallet | [Zallet](https://github.com/zcash/zallet) |

This repository is a thin Docker/CI wrapper around **`zcashd` only**. It does **not** package Zebra or Zallet. Inventing a half-finished Zebra image here is out of scope; stand up supported stacks under their own packaging.

## CI (fail-closed)

- **`watch-release`**: no automatic `VERSION` bump → `main` → image publish. Cron still may run but **exits 1 with an EOL message** and never pushes.
- **`build`**: push to `main` / default dispatch **fails** with an EOL message (no GHCR push). Optional `allow_archival_build=true` on `workflow_dispatch` is for **historical/offline** builds only — not mainnet.

## Archival build (local only)

If you need an offline copy of the last `zcashd` packaging for forensics or testnet archaeology:

```bash
# Requires explicit override; still not mainnet-ready
docker buildx build \
  --build-arg VERSION=$(tr -d '[:space:]' < VERSION) \
  --build-arg "APT_KEY_FPRS=$(tr '\n' ' ' < KEYS | tr -s ' ')" \
  --platform linux/amd64 \
  -t zcash-archival:$(tr -d '[:space:]' < VERSION) \
  docker/
```

Integrity notes for residual Dockerfile:

- **Apt keys:** fingerprints in `KEYS` are asserted after `curl` of `https://apt.z.cash/zcash.asc` and before `gpg --dearmor`.
- **Params:** not baked into the image (daemon is EOS-halted; downloading ~760MB unverified params was both waste and a supply-chain gap).

## Layout

| Path | Role |
| --- | --- |
| `VERSION` | Last packaged `zcashd` version (`6.20.0`) — **not** a support claim |
| `KEYS` | Live `apt.z.cash` key fingerprints (asserted in Dockerfile) |
| `docker/Dockerfile` | Archival multi-stage image (amd64 apt / arm64 source) |
| `docker/docker-entrypoint.sh` | Entry + optional `gosu` drop for zcash binaries |
| `.github/workflows/build.yml` | Fail-closed; archival override only |
| `.github/workflows/watch-release.yml` | Fail-closed; no unattended main publish |
| `DEPRECATION.md` | Full EOS / migration / CI policy |

## License

MIT
