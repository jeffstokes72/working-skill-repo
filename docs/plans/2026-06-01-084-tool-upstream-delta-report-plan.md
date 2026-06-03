---
kb_id: kb-2026-06-01-claude-remaining-hardening
slice_id: slice-084
title: "Add read-only ATV upstream delta report"
blockers: []
verification: integration
test_level: functional-cli
functional_risk: narrow
hitl: false
expected_files:
  - path: scripts/atv-upstream-delta.ps1
    op: create
    scope: "Generate a read-only categorized report comparing working repo, local ATV fork, and original ATV upstream."
  - path: scripts/atv-upstream-delta-selftest.ps1
    op: create
    scope: "Selftest classification behavior against a small fixture or mock git surface."
  - path: config/atv-upstream-delta.json
    op: create
    scope: "Store category rules for KB-owned, shared-overlap, ATV-native, superseded, and unknown skills."
  - path: README.md
    op: edit
    scope: "Document read-only upstream delta workflow and no-apply boundary."
  - path: docs/context/operations/testing.md
    op: edit
    scope: "Add upstream delta report proof command."
protected_oracles:
  - path: scripts/atv-upstream-delta-selftest.ps1
    role: "upstream delta classification oracle"
    sha256: "eca55c91fe7779bb786aa3d19680f07839db3eb2aa70b136bbb161547f167848"
    update_policy: "requires explicit plan update"
status: completed
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Completed. Use the report for read-only upstream triage; no apply mode exists."
human_action: ""
can_continue_other_slices: true
---

# Slice 084: Read-Only Upstream Delta Report

## What To Build

Add a read-only report that explains what changed in original ATV upstream and
whether this repo should care. The script must not copy, restore, delete, or
install anything.

## Acceptance Criteria

- Report compares original ATV `upstream/main` to the local ATV/fork state using
  git object reads or read-only diff commands.
- Report classifies changes as `kb-owned-reject`, `shared-overlap-review`,
  `atv-native-candidate`, `superseded-workflow-reject`, or `unknown-review`.
- Report explicitly calls out security-sensitive regressions such as dropping
  OSV proof from `atv-security`.
- Selftest proves category matching and no-apply behavior.
- Docs explain upstream delta in plain language.

## Test Scenarios

- Run `powershell -ExecutionPolicy Bypass -File scripts/atv-upstream-delta-selftest.ps1`.
- Run `powershell -ExecutionPolicy Bypass -File scripts/atv-upstream-delta.ps1`.
- Confirm `git -C <atv-repo> status --short` is not mutated by the report.
- Run `.\.github\skills\kb-check\scripts\kb-check.ps1 -All`.

## Scope Boundary

- No apply mode.
- No global installs.
- No automatic upstream merge.

## Dependencies

None.
