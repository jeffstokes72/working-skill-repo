---
kb_id: kb-2026-07-05-phoenix-proof-spine-merge
slice_id: slice-006
title: "Refresh docs, eval map, release proof, and sync targets"
blockers: [slice-002, slice-003, slice-004, slice-005]
verification: verification-only
test_level: none
functional_risk: none
model_tier: small
tier_reason: "Mostly mechanical docs, eval-map, release checks, and propagation once prior slices define exact behavior."
escalate_to_large_when:
  - "sync drift contains conflicting human edits"
  - "release gate reveals architecture or policy contradiction"
hitl: false
expected_files:
  - path: README.md
    op: edit
    scope: "document visible workflow changes if user-facing commands or installed skill list changes"
  - path: AGENTS.md
    op: edit
    scope: "document skill sync or release contract changes only if needed"
  - path: docs/context/eval-map.md
    op: edit
    scope: "add proof-spine and model-tier contract checks"
  - path: docs/context/operations/testing.md
    op: edit
    scope: "final command list for sense/accept/adoption/model-tier checks"
  - path: docs/context/research/README.md
    op: edit
    scope: "keep Phoenix research note indexed"
  - path: config/skill-quality.json
    op: edit
    scope: "add release/sync checks only if new validators need registration"
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Run the release/sync gate, refresh docs, sync the approved skills to globals and ATV targets, then record proof."
human_action: ""
can_continue_other_slices: true
---

# Slice 006 - docs/eval/sync cleanup

## What To Build

Finish the merge as a portable skill-bundle change:

- update user-facing docs only where workflow behavior changed;
- update eval map and testing docs with the new deterministic commands;
- run the release/sync gate;
- propagate final approved skills to required global and ATV skill roots per
  `AGENTS.md`;
- record proof and drift results.

## Acceptance Criteria

- `go run ./cmd/kbcheck core` passes.
- `go run ./cmd/kbcheck local-release` passes or reports only documented,
  intentional optional warnings.
- `git diff --check` passes in every touched repo.
- Required skill copies match by hash after sync:
  `~/.codex/skills`, `~/.copilot/skills`, `~/.agents/skills`, and
  `<atv-repo>/.github/skills`.
- ATV scaffold/plugin copies are touched only if this change intentionally ships
  those surfaces.

## Test Scenarios

- Release gate catches any missing validator/doc contract.
- Sync report catches drift before overwrite.
- Hash comparison proves required target copies match after sync.

## Scope Boundary

No new Phoenix feature work here. This slice only completes docs, proof, and
propagation for prior slices.

## Verification

Run:

```shell
go run ./cmd/kbcheck core
go run ./cmd/kbcheck local-release
git diff --check
```
