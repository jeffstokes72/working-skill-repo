---
kb_id: kb-2026-06-01-claude-remaining-hardening
slice_id: slice-082
title: "Classify skill and reviewer-agent minimality"
blockers: []
verification: integration
test_level: functional-cli
functional_risk: medium
hitl: false
expected_files:
  - path: scripts/skill-surface-minimality.ps1
    op: create
    scope: "Classify skills/agents as required, conditional, unproven, unused, or trim-candidate without deleting them."
  - path: scripts/skill-surface-minimality-selftest.ps1
    op: create
    scope: "Selftest classification on a small fixture tree."
  - path: .github/skills/kb-check/scripts/kb-check.ps1
    op: edit
    scope: "Wire minimality selftest/report into the canonical All gate if appropriate."
  - path: README.md
    op: edit
    scope: "Document proof-before-deletion policy and report command."
  - path: docs/context/operations/testing.md
    op: edit
    scope: "Add minimality report to verification surfaces."
protected_oracles:
  - path: scripts/skill-surface-minimality-selftest.ps1
    role: "minimality report behavior oracle"
    sha256: "d87f43751d408058923517492c5a595080734a40c02786e3faa238c9404c4d4e"
    update_policy: "requires explicit plan update"
status: completed
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Completed. Use the report as cold-storage evidence; do not delete anything from this slice."
human_action: ""
can_continue_other_slices: true
---

# Slice 082: Skill Surface Minimality Report

## What To Build

Add a classification report for skill and reviewer-agent surface area. The
report must support deletion decisions later, but this slice performs no
deletions and no trim edits.

## Acceptance Criteria

- Report maps workflow skills to referenced reviewer/specialist agents where
  references can be found statically.
- Report classifies entries as `required`, `conditional`, `unproven`,
  `unused-candidate`, or `trim-candidate`.
- Report includes line/token estimates from existing surface tooling where
  useful.
- Output contains a cold-storage candidate list, not an automatic deletion list.
- Selftest proves classification labels on fixtures.

## Test Scenarios

- Run `powershell -ExecutionPolicy Bypass -File scripts/skill-surface-minimality-selftest.ps1`.
- Run `powershell -ExecutionPolicy Bypass -File scripts/skill-surface-minimality.ps1`.
- Run `.\.github\skills\kb-check\scripts\kb-check.ps1 -All`.

## Scope Boundary

- Do not delete or trim skills/agents in this slice.
- Do not remove globals or ATV copies.
- Do not claim runtime proof when the report is static-only; label such findings
  `unproven`.

## Dependencies

None.
