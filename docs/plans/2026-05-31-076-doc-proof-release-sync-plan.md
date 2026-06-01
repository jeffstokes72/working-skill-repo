---
kb_id: kb-2026-05-31-atv-upstream-resync
slice_id: slice-076
title: "Run proof and update release memory"
blockers: [slice-072, slice-073, slice-074, slice-075]
verification: full-gate
test_level: integration
functional_risk: medium
hitl: false
expected_files:
  - path: "README.md"
    op: update
    scope: "Document any visible workflow/install/sync changes."
  - path: "E:\\all-the-vibes\\README.md"
    op: update
    scope: "Document ATV-facing changes when scaffold/plugin behavior changes."
  - path: "docs/context/PROJECT.md"
    op: update
    scope: "Refresh current truth and route map if the resync changes them."
  - path: "todo.md"
    op: update
    scope: "Queue/result status for this manifest."
  - path: "todo-done.md"
    op: update
    scope: "Completed work summary after verification."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Run gates, update docs/memory, and produce check-in readiness summary."
human_action: ""
can_continue_other_slices: false
---

# Slice 076: Proof And Release Sync

## Acceptance Criteria

- Canonical gate passes: `.\.github\skills\kb-check\scripts\kb-check.ps1 -All`.
- `scripts\skill-sync-report.ps1` reports zero required issues.
- `git diff --check` passes in `E:\working-skill-repo` and
  `E:\all-the-vibes`.
- README/project memory/todo files reflect the new source-of-truth boundaries.
- Final summary lists accepted upstream imports, rejected deletions, quarantined
  candidates, and remaining parked work.

## Test Scenarios

- `.\.github\skills\kb-check\scripts\kb-check.ps1 -All`
- `scripts\skill-sync-report.ps1`
- `git diff --check`
- `git -C E:\all-the-vibes diff --check`
