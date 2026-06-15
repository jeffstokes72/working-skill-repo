---
kb_id: kb-2026-06-01-go-validator-port-wave-1
slice_id: slice-121
title: "Port swarm proof utilities to native Go"
blockers: []
verification: integration
test_level: functional-cli
functional_risk: medium
hitl: false
expected_files:
  - path: cmd/kbcheck/swarm.go
    op: create
    scope: "Implement ready-set and scope-lease commands plus native selftests."
  - path: cmd/kbcheck/swarm_test.go
    op: create
    scope: "Prove native ready-set and scope-lease behavior."
  - path: cmd/kbcheck/main.go
    op: edit
    scope: "Route the new utility commands."
  - path: cmd/kbcheck/checks.go
    op: edit
    scope: "Replace PowerShell selftest checks with native Check.Run hooks."
  - path: cmd/kbcheck/checks_test.go
    op: edit
    scope: "Update skill-repo discovery expectations for native selftests."
  - path: cmd/kbcheck/parity_test.go
    op: edit
    scope: "Update parity expectations for native selftests."
  - path: scripts/kb-work-ready-set.ps1
    op: delete
    scope: "Remove legacy PowerShell implementation after Go parity lands."
  - path: scripts/kb-work-ready-set-selftest.ps1
    op: delete
    scope: "Remove legacy PowerShell selftest after Go parity lands."
  - path: scripts/kb-work-scope-lease.ps1
    op: delete
    scope: "Remove legacy PowerShell implementation after Go parity lands."
  - path: scripts/kb-work-scope-lease-selftest.ps1
    op: delete
    scope: "Remove legacy PowerShell selftest after Go parity lands."
protected_oracles: []
status: done
---

# Slice 121: Port Swarm Proof Utilities To Native Go

## What To Build

Move the bounded-swarm proof utilities from PowerShell into `cmd/kbcheck`:

- `kbcheck ready-set --manifest <path> [--json]`
- `kbcheck ready-set-selftest`
- `kbcheck scope-lease --ledger <path> [--json]`
- `kbcheck scope-lease-selftest`

## Acceptance Criteria

- Native Go commands return the same pass/fail semantics as the deleted scripts.
- `cmd/kbcheck core --list` still includes:
  - `kb-work-ready-set-selftest`
  - `kb-work-scope-lease-selftest`
- `cmd/kbcheck core` runs those checks without invoking PowerShell.
- The four superseded `.ps1` files are deleted.
- Docs no longer point users at deleted scripts.

## Test Scenarios

- `go run ./cmd/kbcheck ready-set-selftest`
- `go run ./cmd/kbcheck scope-lease-selftest`
- `go test ./...`
- `go run ./cmd/kbcheck core --list`

## Scope Boundary

- Do not port unrelated PowerShell scripts in this slice.
- Do not remove PowerShell as a full-suite prerequisite yet; most validators
  still remain `.ps1`.

## Completion Proof

- Added native commands and Go tests.
- Removed the four superseded scripts.
- `go run ./cmd/kbcheck ready-set-selftest` exited 0.
- `go run ./cmd/kbcheck scope-lease-selftest` exited 0.
