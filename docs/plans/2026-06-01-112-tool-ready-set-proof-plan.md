---
kb_id: kb-2026-06-01-kb-work-swarm-ready-set
slice_id: slice-112
title: "Add deterministic ready-set proof"
blockers: [slice-111]
verification: integration
test_level: functional-cli
functional_risk: narrow
hitl: false
expected_files:
  - path: scripts/kb-work-ready-set.ps1
    op: create
    scope: "Read a KB manifest and emit the currently dispatchable ready set from blockers, statuses, and can_continue_other_slices."
  - path: scripts/kb-work-ready-set-selftest.ps1
    op: create
    scope: "Build fixture manifests that prove blocked, done, false-continuation, and independent ready-set behavior."
  - path: cmd/kbcheck/checks.go
    op: edit
    scope: "Add the ready-set selftest to the core check list if it stays cheap and deterministic."
  - path: docs/context/operations/testing.md
    op: edit
    scope: "Document the ready-set proof command."
protected_oracles: []
status: done
---

# Slice 112: Add Deterministic Ready-Set Proof

## What To Build

Add a small checker that computes which manifest slices are currently eligible
to run together. This is not an executor. It only proves the dispatch rule that
`kb-work` is expected to follow.

Ready means:

- slice status is `pending`;
- every blocker is `done` or `skipped`;
- `can_continue_other_slices` is true, unless it is the only runnable slice;
- no dependency cycle is present.

## Acceptance Criteria

- The checker reports ready slice IDs for a manifest.
- The selftest proves:
  - independent pending slices can be returned together;
  - blocked slices are excluded;
  - `done`, `skipped`, `blocked`, and `human-required` slices are excluded;
  - `can_continue_other_slices: false` prevents co-dispatch with other ready
    slices;
  - cycles fail deterministically.
- The check is deterministic-local and cheap enough for `kbcheck core`.

## Test Scenarios

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kb-work-ready-set-selftest.ps1`
- `go run .\cmd\kbcheck core`

## Scope Boundary

- Do not spawn agents.
- Do not run slice work.
- Do not infer file disjointness from `expected_files`; that belongs to slice
  113.

## Completion Proof

- Added `scripts/kb-work-ready-set.ps1`.
- Added `scripts/kb-work-ready-set-selftest.ps1`.
- Added the selftest to `cmd/kbcheck`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kb-work-ready-set-selftest.ps1`
  exited 0.
