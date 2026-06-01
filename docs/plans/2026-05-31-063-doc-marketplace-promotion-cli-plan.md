---
kb_id: kb-2026-05-31-marketplace-promotion-cli
slice_id: slice-063
title: "Document the safe fast path"
blockers: [slice-062]
verification: verification-only
test_level: functional-cli
functional_risk: narrow
hitl: false
expected_files:
  - path: "README.md"
    op: edit
    scope: "Document promote-marketplace-skill.ps1 as the safe fast path."
  - path: "docs/context/architecture/private-skill-marketplace.md"
    op: edit
    scope: "Record the command and direct-install avoidance rule."
  - path: "docs/context/operations/testing.md"
    op: edit
    scope: "Record promotion selftest in the check suite."
  - path: "todo.md"
    op: edit
    scope: "Move queued promotion CLI work through done state."
  - path: "todo-done.md"
    op: edit
    scope: "Archive completion summary."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Update docs and board."
human_action: ""
can_continue_other_slices: true
---

# Slice 063: Docs

## Acceptance Criteria

- README says the safe path is the fast path.
- Private marketplace architecture doc names the command and boundary.
- Testing docs list the selftest.
- Board no longer carries an active queued item for completed work.
