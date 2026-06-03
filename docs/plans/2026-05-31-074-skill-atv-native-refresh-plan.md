---
kb_id: kb-2026-05-31-atv-upstream-resync
slice_id: slice-074
title: "Refresh ATV-native skills"
blockers: [slice-071]
verification: review-plus-lint
test_level: structural
functional_risk: medium
hitl: false
expected_files:
  - path: "E:\\all-the-vibes\\.github\\skills\\atv-security\\**"
    op: update
    scope: "Refresh upstream ATV security docs/fixes while preserving OSV proof additions."
  - path: "E:\\all-the-vibes\\.github\\skills\\create-agent-skills\\**"
    op: update
    scope: "Import upstream skill-creation fixes if still ATV-owned."
  - path: "E:\\all-the-vibes\\.github\\skills\\git-*\\*"
    op: update
    scope: "Import upstream git helper fixes where applicable."
  - path: "E:\\all-the-vibes\\.github\\skills\\land\\SKILL.md"
    op: update
    scope: "Import upstream release helper fixes where applicable."
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Review upstream ATV-native deltas and copy only approved updates into ATV fork roots; mirror into working repo only when the portable bundle owns that skill."
human_action: ""
can_continue_other_slices: true
---

# Slice 074: ATV-Native Refresh

## Acceptance Criteria

- Separates ATV-owned skills from portable KB-owned skills.
- Preserves local OSV/security additions when importing upstream ATV security
  user-guide changes.
- Does not copy ATV-native skills into globals unless they are intentionally
  part of the approved global bundle.
- Records every imported upstream source ref/path in the audit artifact.

## Test Scenarios

- `git -C <atv-repo> diff --check`.
- Run ATV security self/proof command if the skill exposes one.
- Run repo-level `kb-check -All` after any mirrored portable-skill change.
