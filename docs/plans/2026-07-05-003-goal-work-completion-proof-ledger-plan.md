---
kb_id: kb-2026-07-05-phoenix-proof-spine-merge
slice_id: slice-003
title: "Require proof ledger in goal/work/complete"
blockers: [slice-001]
verification: integration
test_level: integration
functional_risk: broad
model_tier: large
tier_reason: "Completion semantics cross durable goals, work manifests, gates, and terminal proof."
escalate_to_large_when:
  - "always large; this slice sets cross-workflow completion policy"
hitl: false
expected_files:
  - path: .github/skills/kb-goal/SKILL.md
    op: edit
    scope: "durable goals record objective sensors and terminal accept/proof evidence"
  - path: .github/skills/kb-work/SKILL.md
    op: edit
    scope: "slice execution records accept evidence when available and does not mark done on prose"
  - path: .github/skills/kb-complete/SKILL.md
    op: edit
    scope: "terminal proof gate prefers kbcheck accept and trace/log artifacts"
  - path: .github/skills/kb-gate/SKILL.md
    op: edit
    scope: "gate policy recognizes trace-derived accept evidence"
  - path: docs/context/architecture/kb-workflow.md
    op: edit
    scope: "document proof-ledger flow for goal/work/complete"
  - path: cmd/kbcheck/manifest_contract_test.go
    op: edit
    scope: "optional manifest contract coverage if proof-ledger fields become validated"
  - path: cmd/kbcheck/manifest_contract.go
    op: edit
    scope: "optional manifest contract coverage for proof-ledger fields"
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Thread the proof-spine concept through goal/work/complete without duplicating Phoenix lifecycle vocabulary."
human_action: ""
can_continue_other_slices: true
---

# Slice 003 - goal/work/complete proof ledger

## What To Build

Make the KB terminal loop prefer computed proof:

- `kb-goal` records the goal sensor, target check id, and terminal evidence.
- `kb-work` records per-slice accept evidence when an oracle exists.
- `kb-complete` treats `kbcheck accept`, command/test output, browser/API/CLI
  probes, and trace/log artifacts as valid proof, and rejects prose-only proof.
- `kb-gate` documents when missing executable proof blocks advancement.

This is where Phoenix's "acceptance from trace state" becomes KB-native.

## Acceptance Criteria

- Durable goals cannot be marked complete without terminal evidence matching the
  original objective.
- Slice completion guidance says tests passing is a progress state unless proof
  is recorded in the manifest.
- Completion guidance names `kbcheck accept` as the preferred proof for repaired
  failures with a known oracle.
- Existing non-failure work can still complete with deterministic command,
  browser/API/CLI, snapshot, or trace/log evidence.

## Test Scenarios

- Manifest/gate selftests still pass.
- If manifest proof fields become deterministic, tests reject missing proof and
  accept a valid proof-ledger example.

## Scope Boundary

No learning promotion changes here. No global replacement of `kb-regression-snapshot`.

## Verification

Run:

```shell
go test ./cmd/kbcheck/...
go run ./cmd/kbcheck workflow-governor-selftest
go run ./cmd/kbcheck core
```
