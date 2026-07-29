# DEPRECATED — do not deploy for mainnet

**Status:** END OF SUPPORT / **do not deploy** as a live mainnet Zcash node.

| Field | Value |
| --- | --- |
| Package | `ghcr.io/kub0-ai/zcash` (this repo) |
| Pinned VERSION | `6.20.0` (`zcashd`) |
| Upstream EOS halt | block height **3417100** (reached **2026-07-18**) |
| Effect | Unmodified `zcashd` 6.20.0 **shuts down and refuses to restart** past the deprecation height; **no NU6.3** support |

## Why this package is retired

Electric Coin Company / Zcash upstream ended support for the `zcashd` consensus client. Official guidance is to migrate:

- **Consensus / full node:** [Zebra](https://github.com/ZcashFoundation/zebra) (`zebrad`)
- **Wallet:** [Zallet](https://github.com/zcash/zallet) (and related migration tooling; see also Zakura where applicable)

This packaging tree only wraps `zcashd`. Shipping `6.20.0` as `ghcr.io/kub0-ai/zcash:latest` would be **false readiness** for post-halt mainnet.

## CI policy (fail-closed)

1. **`watch-release.yml`** — schedule and auto-bump of `VERSION` on `main` are **disabled**. The workflow exits with an explicit EOL message and does **not** `git push origin HEAD:main`.
2. **`build.yml`** — default path **fails closed** with an EOL message and does **not** push `ghcr.io/kub0-ai/zcash:{version,latest}`. An optional `workflow_dispatch` input `allow_archival_build=true` exists only for offline/historical image builds; it must never be treated as mainnet-ready.

## What operators should do

| Need | Use |
| --- | --- |
| Mainnet node | Zebra (`zebrad`), not this image |
| Wallet / funds from old `wallet.dat` | Zallet migration path (upstream docs) |
| Residual lab/testnet experiments | Build outside this pipeline; do not pull `:latest` from this package for production |

## Related audit trail

- Packaging findings: `agent-memory/audit/zcash/findings-m-20260729-215523-ec30-lap1.md`
- Upstream EOS: `agent-memory/audit/upstream-zcash/findings-m-20260729-215612-5266-lap1.md`
- Remediation note: `agent-memory/audit/zcash/remediation-m-20260729-220257-98ac.md`

## Historical note on KEYS

The former `KEYS` entry `3FE63B67F85EA808DE9B880E6DEF3BAF272766C0` (Zcash Master Signing Key) **expired 2024-10-30** and was never consumed by the Dockerfile (apt used HTTPS TOFU for `zcash.asc`). Current `KEYS` pins live `apt.z.cash` fingerprints asserted at build time for archival builds only.
