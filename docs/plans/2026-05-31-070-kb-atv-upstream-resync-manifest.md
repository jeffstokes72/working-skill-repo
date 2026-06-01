---
type: kb-manifest
kb_id: kb-2026-05-31-atv-upstream-resync
brainstorm_path: skipped-clear
created: 2026-05-31
status: completed
workflow_shape: "multi-stream-epic"
scope-verified-files:
  - docs/context/epics/atv-upstream-resync.md
  - docs/plans/2026-05-31-070-kb-atv-upstream-resync-manifest.md
  - docs/plans/2026-05-31-071-tool-atv-clean-integration-audit-plan.md
  - docs/plans/2026-05-31-072-skill-shared-overlap-merge-plan.md
  - docs/plans/2026-05-31-073-skill-kb-preservation-propagation-plan.md
  - docs/plans/2026-05-31-074-skill-atv-native-refresh-plan.md
  - docs/plans/2026-05-31-075-superseded-workflow-cleanup-plan.md
  - docs/plans/2026-05-31-076-doc-proof-release-sync-plan.md
slices:
  - id: slice-071
    title: "Build clean ATV integration inventory"
    path: docs/plans/2026-05-31-071-tool-atv-clean-integration-audit-plan.md
    blockers: []
    verification: audit-artifact
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Create a clean compare surface or use git object reads to inventory origin/main vs upstream/main by skill category."
    human_action: ""
    can_continue_other_slices: false
    notes: "scope-check: forecast=1 changed=1 discovered=0 unexplained=0; proof: created docs/context/research/2026-05-31-atv-upstream-skill-delta.md from git object reads; memory-impact: durable; refresh=pending"
    protected_oracles: []
  - id: slice-072
    title: "Merge shared overlap skills"
    path: docs/plans/2026-05-31-072-skill-shared-overlap-merge-plan.md
    blockers: [slice-071]
    verification: review-plus-lint
    test_level: structural
    functional_risk: medium
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Three-way compare shared CE/learning skills and apply only useful upstream fixes while preserving local trims."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=6 changed=0 discovered=0 unexplained=0; decision: keep local shared CE/learning overlays; focused review check found useful upstream ce-review mechanics already present in local references; proof: kb-check -All passed"
    protected_oracles: []
  - id: slice-073
    title: "Preserve and resync KB-owned skills"
    path: docs/plans/2026-05-31-073-skill-kb-preservation-propagation-plan.md
    blockers: [slice-071]
    verification: sync-report
    test_level: structural
    functional_risk: medium
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Reject upstream KB deletions, confirm tracked KB skill inventory, and resync approved KB copies across global/ATV roots."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=4 changed=0 discovered=0 unexplained=0; decision: rejected upstream KB deletions; proof: skill-sync-report reported 216 comparisons, 0 required issues"
    protected_oracles: []
  - id: slice-074
    title: "Review ATV-native skills selectively"
    path: docs/plans/2026-05-31-074-skill-atv-native-refresh-plan.md
    blockers: [slice-071]
    verification: review-plus-lint
    test_level: structural
    functional_risk: medium
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Review upstream fixes for ATV-owned skills that this bundle mirrors or depends on, and keep only used or useful changes."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=4 changed=ATV roots only; policy-correction: original ATV is a source to mine, not a mirror target; rejected atv-security A06 regression that removed OSV proof; proof: git -C E:\\all-the-vibes diff --check passed"
    protected_oracles: []
  - id: slice-075
    title: "Clean up superseded ATV workflow candidates"
    path: docs/plans/2026-05-31-075-superseded-workflow-cleanup-plan.md
    blockers: [slice-071]
    verification: audit-artifact
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Remove transient upstream workflow imports and keep improvements queued for KB/CE replacement skills."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=7 changed=11 transient ATV root dirs removed; lfg, slfg, and workflows-* are superseded by klfg/kb lanes unless an app use case re-approves them; OSV limited scan returned no package sources during transient import; globals contained no workflow skill dirs"
    protected_oracles: []
  - id: slice-076
    title: "Run proof and update release memory"
    path: docs/plans/2026-05-31-076-doc-proof-release-sync-plan.md
    blockers: [slice-072, slice-073, slice-074, slice-075]
    verification: full-gate
    test_level: integration
    functional_risk: medium
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Run canonical gates, update README/project memory/todo summaries, and report what is safe to check in."
    human_action: ""
    can_continue_other_slices: false
    notes: "scope-check: forecast=5 changed=manifest/docs/todo; proof: kb-check -All passed; skill-sync-report 216 comparisons, 0 required issues; git diff --check passed in working repo, ATV, and marketplace with line-ending warnings only"
    protected_oracles: []
---

# KB: ATV Upstream Resync

## Origin

Epic: `docs/context/epics/atv-upstream-resync.md`

## Workflow Shape

`multi-stream-epic` - upstream resync spans two repos, global installs,
marketplace quarantine policy, shared skill forks, and proof gates.

## Slice Overview

| # | Slice | Blocked By | Verification | HITL | Status |
|---|---|---|---|---|---|
| 1 | Build clean ATV integration inventory | - | audit-artifact | no | done |
| 2 | Merge shared overlap skills | slice-071 | review-plus-lint | no | done |
| 3 | Preserve and resync KB-owned skills | slice-071 | sync-report | no | done |
| 4 | Review ATV-native skills selectively | slice-071 | review-plus-lint | no | done |
| 5 | Clean up superseded ATV workflow candidates | slice-071 | audit-artifact | no | done |
| 6 | Run proof and update release memory | slice-072, slice-073, slice-074, slice-075 | full-gate | no | done |

## Final Proof

- `.\.github\skills\kb-check\scripts\kb-check.ps1 -All` passed.
- `scripts\skill-sync-report.ps1` reported `216 comparisons, 0 required issues`.
- `git diff --check` passed in `E:\working-skill-repo`,
  `E:\all-the-vibes`, and `E:\agent-marketplace`; only LF/CRLF warnings were
  emitted.
- `osv-scanner` was run narrowly against the transient original-ATV workflow
  skill directories before cleanup and returned `No package sources found`, so
  no vulnerability report was produced.
- Global skill roots contain no `lfg`, `slfg`, `workflows-*`, or `kanban-*`
  directories.
- ATV roots also contain no transient `lfg`, `slfg`, or `workflows-*` imports
  from this pass.

## Completion Review

- Review mode: `local-fallback` because reviewer subagents were not available
  in this runtime without explicit subagent authorization.
- Findings: P0=0 P1=0 P2=0 P3=0.
- Review scope: ATV upstream delta audit, KB preservation decisions,
  superseded workflow cleanup, manifest/docs updates, and proof gates.
- Residual risk: original ATV helper workflows were not functionally exercised
  end to end because they are not part of the active KB/global surface.

## Completion Notes

- `compound`: skipped - this was a sync/provenance update with durable project
  memory already captured in `PROJECT.md`, the epic, and the delta research.
- `learn`: no new instincts; source-of-truth rule recorded in project memory.
- `evolve`: checked at completion count 5; no candidates met local maturity
  gates.
- `kb-map-refresh`: done - updated `README.md`, `docs/context/PROJECT.md`,
  `todo.md`, and `todo-done.md`.

## Execution Notes

- Do not pull directly into dirty `E:\all-the-vibes`.
- Prefer `git show <ref>:<path>` and clean temporary worktrees over checkout.
- Do not accept upstream deletion of KB-owned skills.
- Do not keep original ATV workflow skills merely because upstream has them.
  `lfg`, `slfg`, and `workflows-*` are superseded unless the app uses them.
- Focused review-skill merge check is complete: useful upstream review mechanics
  were already present in local `ce-review` references; keep KB caller names.
