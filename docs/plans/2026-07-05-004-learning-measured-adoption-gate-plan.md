---
kb_id: kb-2026-07-05-phoenix-proof-spine-merge
slice_id: slice-004
title: "Add measured adoption gate to learn/evolve"
blockers: [slice-001]
verification: tdd
test_level: integration
functional_risk: narrow
model_tier: large
tier_reason: "Promotion policy must preserve scoped learning while adding a measured gate for shared/global changes."
escalate_to_large_when:
  - "always large for policy design; implementation substeps may be medium"
hitl: false
expected_files:
  - path: .github/skills/learn/SKILL.md
    op: edit
    scope: "record measured evidence requirements for upward/shared promotion candidates"
  - path: .github/skills/evolve/SKILL.md
    op: edit
    scope: "require held-out gain/no-regression/human approval before shared/global skill promotion"
  - path: docs/context/architecture/kb-learning-model.md
    op: edit
    scope: "document measured adoption gate as promotion policy, not default memory storage"
  - path: cmd/kbcheck/learning_adoption.go
    op: create
    scope: "deterministic scorer for candidate prompt/skill adoption where fixtures exist"
  - path: cmd/kbcheck/learning_adoption_test.go
    op: create
    scope: "positive gain, insufficient n, right-to-wrong regression, and anti-gaming cases"
  - path: cmd/kbcheck/main.go
    op: edit
    scope: "optional command registration for learning-adoption checks"
protected_oracles:
  - path: cmd/kbcheck/learning_adoption_test.go
    role: "measured promotion acceptance oracle"
    sha256: "filled by kb-work after RED/protection"
    update_policy: "requires explicit plan update"
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Design the measured adoption policy, write failing scorer tests, then wire learn/evolve to require it for shared/global promotion."
human_action: ""
can_continue_other_slices: true
---

# Slice 004 - measured adoption gate for learn/evolve

## What To Build

Port Phoenix's measured-learning idea into KB's existing scoped model:

- Ordinary lessons still default to the narrowest owning scope.
- Promotion to shared/global skill changes requires measured evidence when an
  eval set exists.
- Candidate adoption must pass a held-out comparison, avoid right-to-wrong
  regressions, and require human approval for actual promotion.
- The gate should be deterministic in `cmd/kbcheck` where fixture results exist.

Suggested default thresholds:

- held-out sample count at least 20;
- gain of at least 10 percentage points or at least 2 net additional correct;
- zero right-to-wrong regressions on protected held-out cases;
- no score from hand-authored quality claims alone.

## Acceptance Criteria

- `learn` keeps app/workflow-local storage as the default.
- `evolve` refuses shared/global promotion without either measured gate proof or
  an explicit documented no-fixture exception.
- The scorer rejects insufficient sample size, no meaningful gain, and
  right-to-wrong regression.
- Human approval remains required before generated global/shared skills are
  accepted.

## Test Scenarios

- Positive fixture: candidate clears gain and no-regression threshold.
- Negative fixture: candidate improves easy cases but regresses a protected case.
- Negative fixture: sample count below threshold.
- Negative fixture: hand-authored quality object without computed result.

## Scope Boundary

This slice does not make every local scoped instinct run an eval. The measured
gate applies to promotion/adoption, especially shared/global skill or prompt
changes.

## Verification

Run:

```shell
go test ./cmd/kbcheck/...
go run ./cmd/kbcheck core
```
