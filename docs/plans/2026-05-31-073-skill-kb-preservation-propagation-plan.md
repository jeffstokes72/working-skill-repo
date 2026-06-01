---
kb_id: kb-2026-05-31-atv-upstream-resync
slice_id: slice-073
title: "Preserve and resync KB-owned skills"
blockers: [slice-071]
verification: sync-report
test_level: structural
functional_risk: medium
hitl: false
expected_files:
  - path: ".github/skills/kb-*/**"
    op: update
    scope: "Only for already-approved local KB source changes; do not import upstream deletions."
  - path: ".github/skills/klfg/SKILL.md"
    op: update
    scope: "Preserve if still referenced by KB routing."
  - path: ".github/skills/tdd/SKILL.md"
    op: update
    scope: "Preserve compatibility unless deletion evals exist."
  - path: ".github/skills/todo-*/SKILL.md"
    op: update
    scope: "Preserve lazy todo lanes unless merge/deletion plan proves otherwise."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Confirm tracked KB skill inventory and resync from working repo to globals/ATV roots after accepted shared/ATV changes."
human_action: ""
can_continue_other_slices: true
---

# Slice 073: KB Preservation And Propagation

## Acceptance Criteria

- Upstream deletions of KB-owned skills are explicitly rejected in the audit.
- Working repo remains source of truth for KB skills.
- Global and ATV roots match the working repo for tracked KB/CE skill set.
- No marketplace/quarantine skill is accidentally added to globals.

## Test Scenarios

- `scripts\skill-sync-report.ps1` returns 0 required issues.
- `rg -n "image-backcheck|quarantine" C:\Users\marowe\.codex\skills C:\Users\marowe\.copilot\skills C:\Users\marowe\.agents\skills` only reports approved policy/docs if any.
- `git diff --check` in both repos.
