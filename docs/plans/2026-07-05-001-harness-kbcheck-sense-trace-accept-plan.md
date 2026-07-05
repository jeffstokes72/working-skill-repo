---
kb_id: kb-2026-07-05-phoenix-proof-spine-merge
slice_id: slice-001
title: "Add kbcheck sense/trace/accept proof spine"
blockers: []
verification: tdd
test_level: integration
functional_risk: narrow
model_tier: medium
tier_reason: "Requires CLI and trace-format implementation, but the behavior is narrow and testable."
escalate_to_large_when:
  - "the trace schema affects manifest gate semantics beyond this slice"
  - "the acceptance rule conflicts with protected oracle policy"
hitl: false
expected_files:
  - path: cmd/kbcheck/proof_spine.go
    op: create
    scope: "sense, trace, trace verification, and accept primitives"
  - path: cmd/kbcheck/proof_spine_test.go
    op: create
    scope: "red-green acceptance, vacuous-green rejection, tamper rejection, and command failure tests"
  - path: cmd/kbcheck/main.go
    op: edit
    scope: "register kbcheck sense/trace/accept commands"
  - path: docs/context/operations/testing.md
    op: edit
    scope: "document the proof-spine commands and trace path"
protected_oracles:
  - path: cmd/kbcheck/proof_spine_test.go
    role: "trace-derived acceptance oracle"
    sha256: "filled by kb-work after RED/protection"
    update_policy: "requires explicit plan update"
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Write failing tests first for red-green, vacuous-green, and tamper cases, then implement the CLI proof spine."
human_action: ""
can_continue_other_slices: true
---

# Slice 001 - kbcheck sense/trace/accept proof spine

## What To Build

Add a KB-native proof spine inside `cmd/kbcheck`:

- `kbcheck sense`: run or evaluate an objective check and record a trace event.
- `kbcheck trace-verify`: validate the `.kb/trace.jsonl` hash chain.
- `kbcheck accept`: accept only when the trace proves the named check went
  `red -> green`, the current check is green, and the trace is untampered.

The trace should be ephemeral under `.kb/trace.jsonl`. Manifest summaries can
link to accept results, but the raw working trace does not need to be tracked.

## Acceptance Criteria

- `accept` rejects vacuous green checks that never had a recorded red event.
- `accept` rejects a green current check when trace hash verification fails.
- `accept` passes when a named check records red, then green, and is green now.
- `sense` records enough objective data to audit command, exit code, timestamp,
  check id, and previous hash.
- `go test ./cmd/kbcheck/...` passes.

## Test Scenarios

- RED oracle: an intentionally failing command records a red event.
- GREEN oracle: a later passing command records green for the same check id.
- Vacuous green: a passing-only history is rejected by `accept`.
- Tamper: editing a prior trace line makes `trace-verify` and `accept` fail.
- Missing trace: `accept` fails with a concise actionable error.

## Scope Boundary

No skill behavior changes in this slice. It only provides the executable
primitive used by later slices.

## Verification

Run:

```shell
go test ./cmd/kbcheck/...
go run ./cmd/kbcheck core
```
