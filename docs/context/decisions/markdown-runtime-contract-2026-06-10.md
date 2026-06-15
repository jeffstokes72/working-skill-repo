# Markdown/runtime workflow contract boundary, 2026-06-10

Decision: deterministic workflow rules belong in `kbcheck` or another runtime tool, not long-form skill prose.

Applied now:

- Added `kbcheck manifest-contract --manifest <path>` to validate terminal slice claims against gate-ledger proof.
- Added `kbcheck gate-ledger --manifest <path> --gate <gate-id>` to validate one phase gate before advancement.
- Added the selftest to `core` so the contract stays compiled and regression-tested.

Boundary:

- Keep judgment, scope reasoning, escalation criteria, and tradeoffs in `SKILL.md`.
- Move phase ordering, gate sequencing, proof completeness, and "do not claim done without checks" into deterministic checks.

Reason: always-read deterministic prose still costs tokens and can be rationalized away. Runtime checks are cheaper, stricter, and reusable across hot-path skills.
