---
kb_id: kb-2026-05-31-atv-upstream-resync
slice_id: slice-072
title: "Merge shared overlap skills"
blockers: [slice-071]
verification: review-plus-lint
test_level: structural
functional_risk: medium
hitl: false
expected_files:
  - path: ".github/skills/ce-compound/SKILL.md"
    op: update
    scope: "Only if upstream contains useful fixes not already covered by local trim."
  - path: ".github/skills/ce-compound-refresh/SKILL.md"
    op: update
    scope: "Merge fixes while preserving lazy reference split."
  - path: ".github/skills/ce-review/**"
    op: update
    scope: "Merge review-flow fixes without reintroducing verbose duplicate bodies."
  - path: ".github/skills/document-review/SKILL.md"
    op: update
    scope: "Merge only relevant upstream review skill fixes."
  - path: ".github/skills/evolve/SKILL.md"
    op: update
    scope: "Preserve local approval/landmine behavior."
  - path: ".github/skills/learn/SKILL.md"
    op: update
    scope: "Preserve repo-local learning and scoring model."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "For each shared skill, compare local source, ATV origin, and upstream; patch local source only when upstream adds net value."
human_action: ""
can_continue_other_slices: true
---

# Slice 072: Shared Overlap Merge

## Acceptance Criteria

- Findings-first note for each skill: upstream delta, local delta, decision.
- Keeps locally trimmed/lazy-loaded structure unless upstream fixes a real bug.
- Does not re-add deleted reference files merely because upstream has older
  verbose decomposition.
- Syncs accepted local source changes to globals and ATV tracked roots after
  review.

## Test Scenarios

- `scripts\skill-lint.ps1` through `kb-check -All`.
- `scripts\skill-sync-report.ps1`.
- Targeted `git diff --check`.
