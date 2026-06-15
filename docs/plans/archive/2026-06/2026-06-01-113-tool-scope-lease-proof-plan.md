---
kb_id: kb-2026-06-01-kb-work-swarm-ready-set
slice_id: slice-113
title: "Add observed overlap and lease proof"
blockers: [slice-111]
verification: integration
test_level: functional-cli
functional_risk: medium
hitl: false
expected_files:
  - path: scripts/kb-work-scope-lease.ps1
    op: create
    scope: "Validate a simple slice/file lease or observed write ledger and fail on active overlapping writes."
  - path: scripts/kb-work-scope-lease-selftest.ps1
    op: create
    scope: "Prove disjoint writes pass, overlapping active writes fail, and completed/requeued leases release correctly."
  - path: cmd/kbcheck/checks.go
    op: edit
    scope: "Add the scope-lease selftest to the core check list if deterministic and cheap."
  - path: docs/context/operations/testing.md
    op: edit
    scope: "Document the lease/overlap proof command and its limits."
protected_oracles: []
status: done
---

# Slice 113: Add Observed Overlap And Lease Proof

## What To Build

Define the smallest proof primitive for safe swarming: a deterministic check
that fails when two active slices claim or observe writes to the same path
without an explicit serialization/requeue decision.

This can be a lease file, a manifest note parser, or a JSON/JSONL ledger. Keep
the format simple enough to inspect by hand.

## Acceptance Criteria

- The selftest proves overlapping active writes fail.
- The selftest proves disjoint active writes pass.
- Completed, skipped, or requeued ownership releases the path.
- The docs state that `expected_files` is only a forecast; observed writes and
  leases are the safety surface.
- The implementation is local and deterministic; no daemon or external service.

## Test Scenarios

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kb-work-scope-lease-selftest.ps1`
- `go run ./cmd/kbcheck core`

## Scope Boundary

- Do not attempt syscall-level file tracing.
- Do not build a distributed lock service.
- Do not claim this prevents absolute-path or tool-internal writes unless the
  write ledger is actually populated by the runtime.

## Completion Proof

- Added `scripts/kb-work-scope-lease.ps1`.
- Added `scripts/kb-work-scope-lease-selftest.ps1`.
- Added the selftest to `cmd/kbcheck`.
- Fixed Windows PowerShell JSON array wrapping in the lease validator.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kb-work-scope-lease-selftest.ps1`
  exited 0.
