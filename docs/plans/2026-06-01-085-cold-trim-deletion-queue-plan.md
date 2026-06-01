---
kb_id: kb-2026-06-01-claude-remaining-hardening
slice_id: slice-085
title: "Park trim and deletion execution queue"
blockers: [slice-082]
verification: verification-only
test_level: none
functional_risk: none
hitl: false
expected_files:
  - path: todo.md
    op: edit
    scope: "Keep trim/deletion execution in Parked / Cold Storage after classification."
  - path: docs/context/epics/claude-remaining-hardening.md
    op: edit
    scope: "Record trim/deletion as parked until human promotion."
  - path: scripts/skill-surface-minimality.ps1
    op: edit
    scope: "Exclude repo-policy protected skills from cold-storage deletion candidates."
  - path: scripts/skill-surface-minimality-selftest.ps1
    op: edit
    scope: "Prove protected skills do not appear as deletion candidates."
  - path: README.md
    op: edit
    scope: "Document protected minimality classification."
  - path: docs/context/operations/testing.md
    op: edit
    scope: "Document protected minimality classification in testing operations."
protected_oracles: []
status: completed
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Completed: protected CE/document-review dependencies from cold-storage deletion candidates; no deletions were justified by static evidence."
human_action: ""
can_continue_other_slices: true
---

# Slice 085: Cold Trim And Deletion Queue

## What Was Built

The static trim/deletion queue was made safer. `skill-surface-minimality.ps1`
now has a protected classification for repo-policy dependencies such as
`ce-review`, `ce-compound`, `ce-compound-refresh`, and `document-review`, so they
do not appear as deletion candidates merely because static inbound references
are absent or their bodies are long.

No skills or agents were removed. Remaining cold-storage candidates require
runtime usage proof or a focused trim plan before any cut.

## Acceptance Criteria

- `todo.md` cold storage records the remaining proof-required candidates.
- Protected repo-policy skills are excluded from cold-storage deletion
  candidates.
- No skills or agents are removed by this slice.

## Test Scenarios

- Review `todo.md` and the epic after slice-082.
- Run `pwsh -NoProfile -File scripts/skill-surface-minimality-selftest.ps1`.
- Run `pwsh -NoProfile -File scripts/skill-surface-minimality.ps1`.
- Run `git diff --check`.

## Scope Boundary

- Do not remove agents, skills, globals, or ATV copies.

## Completion Evidence

- `pwsh -NoProfile -File scripts/skill-surface-minimality-selftest.ps1` passed.
- `pwsh -NoProfile -File scripts/skill-surface-minimality.ps1` passed.
- Cold-storage candidates dropped from 16 to 12 after protected skills were
  excluded.
- No skill or agent was deleted.

## Dependencies

- Depends on `slice-082` because the parked queue should be seeded from the
  classification report.
