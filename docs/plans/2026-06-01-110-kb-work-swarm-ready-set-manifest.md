---
type: kb-manifest
kb_id: kb-2026-06-01-kb-work-swarm-ready-set
brainstorm_path: "<codex-attachment>/pasted-text.txt"
created: 2026-06-01
status: completed
workflow_shape: "pipeline-change"
scope-verified-files:
  - .github/skills/kb-work/SKILL.md
  - README.md
  - cmd/kbcheck/checks.go
  - docs/context/PROJECT.md
  - docs/context/architecture/kb-workflow.md
  - docs/context/operations/testing.md
  - docs/plans/2026-06-01-110-kb-work-swarm-ready-set-manifest.md
  - docs/plans/2026-06-01-111-skill-kb-work-swarm-contract-plan.md
  - docs/plans/2026-06-01-112-tool-ready-set-proof-plan.md
  - docs/plans/2026-06-01-113-tool-scope-lease-proof-plan.md
  - docs/plans/2026-06-01-114-doc-sync-swarm-contract-plan.md
  - scripts/kb-work-ready-set.ps1
  - scripts/kb-work-ready-set-selftest.ps1
  - scripts/kb-work-scope-lease.ps1
  - scripts/kb-work-scope-lease-selftest.ps1
  - todo.md
  - todo-done.md
slices:
  - id: slice-111
    title: "Invert kb-work to swarm the safe ready set"
    path: docs/plans/2026-06-01-111-skill-kb-work-swarm-contract-plan.md
    blockers: []
    verification: verification-only
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: ""
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Rewrite kb-work and workflow docs so independent ready slices are the default, while shared checkout/file overlap stays serialized."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=3 changed=3 discovered=0 unexplained=0; proof: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\\skill-lint.ps1 exit=0; memory-impact: durable; areas=workflow"
    protected_oracles: []
  - id: slice-112
    title: "Add deterministic ready-set proof"
    path: docs/plans/2026-06-01-112-tool-ready-set-proof-plan.md
    blockers: [slice-111]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: ""
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Add a tiny manifest-ready-set checker/selftest that proves blockers, statuses, and can_continue_other_slices produce the expected swarm set."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=4 changed=3 discovered=0 unexplained=0; proof: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\\kb-work-ready-set-selftest.ps1 exit=0; proof: go run .\\cmd\\kbcheck core --list includes kb-work-ready-set-selftest; memory-impact: durable; areas=testing"
    protected_oracles: []
  - id: slice-113
    title: "Add observed overlap and lease proof"
    path: docs/plans/2026-06-01-113-tool-scope-lease-proof-plan.md
    blockers: [slice-111]
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    owner: ""
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Define and test the minimal observed write-overlap contract so forecasted expected_files never becomes the safety oracle."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=4 changed=3 discovered=0 unexplained=0; proof: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\\kb-work-scope-lease-selftest.ps1 exit=0; proof: go run .\\cmd\\kbcheck core --list includes kb-work-scope-lease-selftest; memory-impact: durable; areas=testing"
    protected_oracles: []
  - id: slice-114
    title: "Propagate swarm contract and prove release"
    path: docs/plans/2026-06-01-114-doc-sync-swarm-contract-plan.md
    blockers: [slice-112, slice-113]
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    owner: ""
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Sync changed skills to globals and ATV roots, update memory, then run the release gate."
    human_action: ""
    can_continue_other_slices: false
    notes: "scope-check: forecast=5 changed=7 discovered=2 unexplained=0; scope-discovery: todo-done.md - completion archive required by kb-work; scope-discovery: docs/plans/* - manifest and slice status updates required by kb-work; proof: go run .\\cmd\\kbcheck local-release --json exit=0 required_failures=0 optional_failures=0; proof: skill-sync-report 222 comparisons, 0 required issues; proof: working/ATV git diff --check exit=0; memory-impact: durable; areas=workflow,testing,sync"
    protected_oracles: []
---

# KB: Work Swarm Ready Set

## Origin

Source: attached critic note from 2026-06-01.

Decision: keep Kanban slices swarm-capable. The current `kb-work` wording
over-corrected toward sequential execution. The desired model is bounded
parallelism: dispatch independent ready slices, but serialize any observed write
overlap or shared checkout risk.

## Workflow Shape

`pipeline-change` - this changes execution semantics, proof tooling, docs, and
skill propagation rules.

## Slice Overview

| # | Slice | Blocked By | Verification | HITL | Status |
|---|---|---|---|---|---|
| 1 | Invert kb-work to swarm the safe ready set | - | verification-only | no | done |
| 2 | Add deterministic ready-set proof | slice-111 | integration | no | done |
| 3 | Add observed overlap and lease proof | slice-111 | integration | no | done |
| 4 | Propagate swarm contract and prove release | slice-112, slice-113 | integration | no | done |

## Non-Negotiables

- Do not build a distributed scheduler, queue service, actor framework, or
  long-running daemon.
- The manifest remains the queue; blockers remain the dependency graph.
- `expected_files` is a forecast, not a safety oracle.
- Parallel work requires isolated contexts/checkouts or a documented runtime
  guarantee that workers cannot mutate the same checkout concurrently.
- Observed write overlap beats planned disjointness.
- Browser/e2e checks stay serialized unless isolated browser sessions are
  explicitly available.

## Done

- `kb-work` describes the swarm model plainly.
- A deterministic ready-set check proves which slices may dispatch together.
- A deterministic overlap/lease selftest proves shared file writes are caught.
- Globals and ATV tracked skill roots match this repo.
- `go run .\cmd\kbcheck local-release` passes.
