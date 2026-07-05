---
kb_id: kb-2026-07-05-phoenix-proof-spine-merge
slice_id: slice-002
title: "Wire repair/troubleshoot to failure-first acceptance"
blockers: [slice-001]
verification: integration
test_level: integration
functional_risk: narrow
model_tier: medium
tier_reason: "Skill text and validator changes are clear once the proof spine exists."
escalate_to_large_when:
  - "repair loop retry semantics need redesign"
  - "acceptance has to cover destructive rollback policy"
hitl: false
expected_files:
  - path: .github/skills/kb-repair/SKILL.md
    op: edit
    scope: "require reproduced failure as a sense event and accept after repair when an oracle exists"
  - path: .github/skills/kb-troubleshoot/SKILL.md
    op: edit
    scope: "turn reproduction and fixed-state checks into traceable sense/accept flow"
  - path: .github/skills/kb-check/SKILL.md
    op: edit
    scope: "document kbcheck accept as preferred executable proof for fixed failures"
  - path: cmd/kbcheck/skill_validators_test.go
    op: edit
    scope: "protect required references if skill lint needs new contract checks"
  - path: cmd/kbcheck/skill_validators.go
    op: edit
    scope: "optional validator for accept/proof language in repair/troubleshoot skills"
protected_oracles:
  - path: cmd/kbcheck/skill_validators_test.go
    role: "repair/troubleshoot skill contract oracle"
    sha256: "filled by kb-work if edited"
    update_policy: "requires explicit plan update when changed"
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Update repair and troubleshoot instructions, then add or adjust validators only if deterministic enforcement is practical."
human_action: ""
can_continue_other_slices: true
---

# Slice 002 - repair/troubleshoot failure-first acceptance

## What To Build

Make `kb-repair` and `kb-troubleshoot` use the new proof spine when a failure can
be reproduced:

- Before editing, record the reproduced failure as a `sense` red event.
- After editing, record the fixed check as green.
- Prefer `kbcheck accept <check-id>` as the completion proof.
- Keep the existing bounded retry/stuck detection behavior.
- Do not require failure-first acceptance for work with no known failing oracle;
  those cases still need the best runnable proof available.

## Acceptance Criteria

- Repair/troubleshoot instructions explicitly reject "looks fixed" as proof when
  a failing oracle exists.
- Existing bounded retry and stuck-detection semantics remain intact.
- `kb-check` points agents to `kbcheck accept` without making prose proof the
  pass/fail oracle.
- Skill lint passes.

## Test Scenarios

- Static validator or grep proves the edited skills mention red reproduction,
  green recheck, and `kbcheck accept`.
- Existing skill validators still pass.

## Scope Boundary

This slice does not change `kb-goal`, `kb-work`, `kb-complete`, or learning
promotion. Those are separate slices.

## Verification

Run:

```shell
go run ./cmd/kbcheck skill-lint
go test ./cmd/kbcheck/...
```
