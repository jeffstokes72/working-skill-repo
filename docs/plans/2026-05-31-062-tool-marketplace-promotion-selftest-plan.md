---
kb_id: kb-2026-05-31-marketplace-promotion-cli
slice_id: slice-062
title: "Add promotion selftest to kb-check"
blockers: [slice-061]
verification: integration
test_level: functional-cli
functional_risk: narrow
hitl: false
expected_files:
  - path: "scripts/promote-marketplace-skill-selftest.ps1"
    op: create
    scope: "Create temp marketplace and skill fixtures, prove happy path and quarantine refusal."
  - path: ".github/skills/kb-check/scripts/kb-check.ps1"
    op: edit
    scope: "Add promotion selftest to the skill-repo check list."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Implement selftest and wire it into kb-check."
human_action: ""
can_continue_other_slices: true
---

# Slice 062: Promotion Selftest

## Acceptance Criteria

- Selftest mutates only `.atv/tmp/...`.
- Happy path creates approved catalog entry and temp global sync copy.
- Negative path fails when approved skill output points into quarantine.
- `kb-check -All` runs the selftest.

## Test Scenarios

- `powershell -ExecutionPolicy Bypass -File scripts/promote-marketplace-skill-selftest.ps1`
- `powershell -ExecutionPolicy Bypass -File ./.github/skills/kb-check/scripts/kb-check.ps1 -All`
