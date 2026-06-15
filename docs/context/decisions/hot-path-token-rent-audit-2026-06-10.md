# Hot-Path Token-Rent Audit

Date: 2026-06-10

## Decision

The 400-line hot-path threshold is a review trigger, not an acceptance criterion.
`kb-brainstorm`, `kb-plan`, and `kb-work` may stay over 400 lines when their
inline sections are justified by an always-path rent table.

## Reason

Lazy-loading content that is needed to route, gate, verify, or prevent unsafe
phase skipping adds another file fetch without reducing actual task context.
Branch rules that the agent must evaluate before deciding a branch does not fire
still pay rent in the hot path.

## Consequences

- Do not shrink these skills solely to satisfy a line-count target.
- Extract only genuinely optional or rarely used material.
- Config allowlist reasons must cite the rent table, not a future deferral.

## Evidence

Rent table: `docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md`

Proof:

```shell
go run ./cmd/kbcheck skill-lint
go run ./cmd/kbcheck route-eval
go run ./cmd/kbcheck core
```
