---
kb_id: kb-2026-06-01-kb-work-swarm-ready-set
slice_id: slice-111
title: "Invert kb-work to swarm the safe ready set"
blockers: []
verification: verification-only
test_level: functional-cli
functional_risk: narrow
hitl: false
expected_files:
  - path: .github/skills/kb-work/SKILL.md
    op: edit
    scope: "Replace one-active-slice default with ready-set swarming and explicit serialization conditions."
  - path: docs/context/architecture/kb-workflow.md
    op: edit
    scope: "Document bounded parallel execution as the KB work model."
  - path: docs/context/operations/testing.md
    op: edit
    scope: "Name the checks that prove ready-set and overlap behavior."
protected_oracles: []
status: done
---

# Slice 111: Invert KB Work To Swarm The Safe Ready Set

## What To Build

Rewrite the `kb-work` execution contract so it defaults to dispatching the safe
ready set instead of one slice at a time. Preserve serialization for shared
checkout mutation, observed file overlap, functional-browser contention,
destructive approvals, HITL, blockers, and dependency deadlocks.

## Acceptance Criteria

- `kb-work` says the runnable unit is the ready independent set:
  blockers satisfied, status pending, and `can_continue_other_slices: true`.
- The previous one-active-slice wording is removed or narrowed to shared
  checkout / non-isolated runtime cases.
- `expected_files` is explicitly treated as a planning forecast only.
- Observed write overlap serializes or requeues one of the colliding slices.
- Docs explain why this is Kanban bounded concurrency, not unlimited
  parallelism.

## Test Scenarios

- `rg -n "one active slice|ready set|can_continue_other_slices|expected_files is a forecast" .github/skills/kb-work/SKILL.md docs/context/architecture/kb-workflow.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/skill-lint.ps1`

## Scope Boundary

- Do not implement a job queue.
- Do not claim true runtime enforcement until slices 112 and 113 add proof.
- Do not remove the safety rule that browser/e2e checks are serialized unless
  isolated sessions exist.

## Completion Proof

- Updated `kb-work` from a sequential default to bounded ready-set swarming.
- Updated KB workflow architecture and testing docs.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\skill-lint.ps1`
  exited 0.
