---
kb_id: kb-2026-05-31-atv-upstream-resync
slice_id: slice-071
title: "Build clean ATV integration inventory"
blockers: []
verification: audit-artifact
test_level: functional-cli
functional_risk: medium
hitl: false
expected_files:
  - path: "docs/context/research/2026-05-31-atv-upstream-skill-delta.md"
    op: create
    scope: "Machine-readable-enough inventory of skill changes by category, source ref, and recommended action."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Inventory origin/main vs upstream/main without mutating dirty worktrees."
human_action: ""
can_continue_other_slices: false
---

# Slice 071: Clean Integration Audit

## Acceptance Criteria

- Records exact refs compared: `origin/main`, `upstream/main`, and current
  working repo head/status.
- Groups changes as KB-owned, shared overlap, ATV-native, new workflow
  candidates, deletions, and branch-only/Pocock candidates.
- Identifies files that are dirty locally before any import.
- Produces a recommended action per skill: keep-local, merge-review,
  import-upstream, quarantine, ignore, or parked.

## Test Scenarios

- `git -C E:\all-the-vibes diff --name-status origin/main..upstream/main -- .github/skills pkg/scaffold/templates/skills plugins/atv-everything/skills`
- `git -C E:\all-the-vibes diff --name-status origin/main..origin/feat/pocock-skills -- .github/skills pkg/scaffold/templates/skills plugins/atv-everything/skills`
- Verify no tracked file changed except the audit artifact.
