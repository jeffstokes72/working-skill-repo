---
kb_id: kb-2026-05-31-marketplace-promotion-cli
slice_id: slice-061
title: "Build single-command marketplace promotion"
blockers: []
verification: integration
test_level: functional-cli
functional_risk: narrow
hitl: false
expected_files:
  - path: "scripts/promote-marketplace-skill.ps1"
    op: create
    scope: "Promote a reviewed skill into the marketplace, pin hash, sync selected globals, and run firebreak."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Implement the promotion script."
human_action: ""
can_continue_other_slices: true
---

# Slice 061: Promotion CLI

## Acceptance Criteria

- Validates source directory and `SKILL.md` frontmatter.
- Requires explicit `-Approved`.
- Copies into approved marketplace skills path and pins SHA256 in catalog.
- Supports selected install targets.
- Refuses approved output under quarantine.
- Runs firebreak after mutation.
- Emits machine-readable JSON with `-Json`.

## Test Scenarios

- Run via temp config in the selftest from slice 062.
