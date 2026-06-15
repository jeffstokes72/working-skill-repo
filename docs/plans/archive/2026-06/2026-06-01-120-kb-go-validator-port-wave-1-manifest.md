---
type: kb-manifest
kb_id: kb-2026-06-01-go-validator-port-wave-1
brainstorm_path: skipped-clear
created: 2026-06-01
status: completed
workflow_shape: "pipeline-change"
scope-verified-files:
  - cmd/kbcheck/checks.go
  - cmd/kbcheck/checks_test.go
  - cmd/kbcheck/main.go
  - cmd/kbcheck/parity_test.go
  - cmd/kbcheck/swarm.go
  - cmd/kbcheck/swarm_test.go
  - docs/context/PROJECT.md
  - docs/context/epics/go-native-validator-port.md
  - docs/context/operations/testing.md
  - docs/plans/archive/2026-06/2026-06-01-120-kb-go-validator-port-wave-1-manifest.md
  - scripts/kb-work-ready-set.ps1
  - scripts/kb-work-ready-set-selftest.ps1
  - scripts/kb-work-scope-lease.ps1
  - scripts/kb-work-scope-lease-selftest.ps1
  - todo-done.md
slices:
  - id: slice-121
    title: "Port swarm proof utilities to native Go"
    path: docs/plans/archive/2026-06/2026-06-01-121-tool-go-swarm-proof-port-plan.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Use cmd/kbcheck ready-set and scope-lease commands; do not restore the deleted PowerShell scripts."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=8 changed=15 discovered=7 unexplained=0; scope-discovery: docs/context/epics/go-native-validator-port.md - durable migration epic; scope-discovery: cmd/kbcheck/main.go - CLI command routing required; scope-discovery: cmd/kbcheck/*_test.go - expectations needed native selftest names; proof: go run .\\cmd\\kbcheck ready-set-selftest exit=0; proof: go run .\\cmd\\kbcheck scope-lease-selftest exit=0; proof: go test ./... exit=0; memory-impact: durable; areas=testing,tooling"
    protected_oracles: []
---

# KB: Go Validator Port Wave 1

## Origin

Human direction: remove PowerShell duplication and move the harness toward Go
instead of maintaining both.

## Slice Overview

| # | Slice | Blocked By | Verification | HITL | Status |
|---|---|---|---|---|---|
| 1 | Port swarm proof utilities to native Go | - | integration | no | done |

## Done

- Added native `kbcheck ready-set` and `kbcheck scope-lease` commands.
- Added native `ready-set-selftest` and `scope-lease-selftest` commands.
- Wired both native selftests into `cmd/kbcheck core`.
- Removed four PowerShell scripts:
  - `scripts/kb-work-ready-set.ps1`
  - `scripts/kb-work-ready-set-selftest.ps1`
  - `scripts/kb-work-scope-lease.ps1`
  - `scripts/kb-work-scope-lease-selftest.ps1`
- Updated docs to point at Go commands.
