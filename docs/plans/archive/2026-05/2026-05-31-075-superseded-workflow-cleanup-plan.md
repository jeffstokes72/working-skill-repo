---
kb_id: kb-2026-05-31-atv-upstream-resync
slice_id: slice-075
title: "Clean up superseded ATV workflow candidates"
blockers: [slice-071]
verification: audit-artifact
test_level: structural
functional_risk: narrow
hitl: false
expected_files:
  - path: "E:\\all-the-vibes\\.github\\skills\\lfg"
    op: delete
    scope: "Remove transient import; superseded by klfg."
  - path: "E:\\all-the-vibes\\.github\\skills\\slfg"
    op: delete
    scope: "Remove transient import; superseded by klfg."
  - path: "E:\\all-the-vibes\\.github\\skills\\workflows-*"
    op: delete
    scope: "Remove transient imports; superseded by KB workflow lanes."
  - path: "E:\\all-the-vibes\\pkg\\scaffold\\templates\\skills\\lfg"
    op: delete
    scope: "Remove transient scaffold import."
  - path: "E:\\all-the-vibes\\pkg\\scaffold\\templates\\skills\\slfg"
    op: delete
    scope: "Remove transient scaffold import."
  - path: "E:\\all-the-vibes\\plugins\\atv-everything\\skills\\lfg"
    op: delete
    scope: "Remove transient plugin import."
  - path: "E:\\all-the-vibes\\plugins\\atv-everything\\skills\\slfg"
    op: delete
    scope: "Remove transient plugin import."
protected_oracles: []
status: done
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Keep superseded workflow skills out unless a current app use case or porting plan re-approves them."
human_action: ""
can_continue_other_slices: true
---

# Slice 075: Superseded Workflow Cleanup

## Acceptance Criteria

- Transient upstream-main candidates `lfg`, `slfg`, and `workflows-*` are not
  present in ATV roots from this pass.
- No marketplace quarantine entries are created for these trusted-but-unused
  ATV skills.
- No global skill directories are created for these skills.
- Branch-only candidates such as `kanban-*` remain parked because they are not
  on original ATV `upstream/main`.
- Useful upstream review improvements are queued for a focused port into
  `kb-review`, `ce-review`, or `document-review`; old workflow entry points are
  not restored just to get those changes.

## Test Scenarios

- `git -C <atv-repo> status --short | Select-String -Pattern 'lfg|slfg|workflows-'`
- `Test-Path <atv-repo>\.github\skills\lfg` returns `False`.
- `Test-Path <atv-repo>\.github\skills\workflows-plan` returns `False`.
- Global skill roots contain no `lfg`, `slfg`, `workflows-*`, or `kanban-*`
  directories.
