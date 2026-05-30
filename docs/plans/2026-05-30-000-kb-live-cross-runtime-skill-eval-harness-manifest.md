---
type: kb-manifest
kb_id: kb-2026-05-30-live-cross-runtime-skill-eval-harness
brainstorm_path: docs/brainstorms/2026-05-30-live-cross-runtime-skill-eval-harness-requirements.md
created: 2026-05-30
status: active
scope-verified-files:
  - docs/brainstorms/2026-05-30-live-cross-runtime-skill-eval-harness-requirements.md
  - docs/context/eval-map.md
  - docs/context/operations/testing.md
  - docs/context/architecture/README.md
  - config/skill-quality.json
  - scripts/skill-eval.ps1
  - scripts/skill-eval-run-codex.ps1
  - evals/skill-eval/result.schema.json
  - evals/route-complexity/README.md
  - .github/skills/kb-check/scripts/kb-check.ps1
slices:
  - id: slice-001
    title: "Add GHCP live skill eval adapter"
    path: docs/plans/2026-05-30-001-tool-ghcp-live-skill-eval-adapter-plan.md
    blockers: []
    verification: functional
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-forecast: loaded 3 expected files + 0 convention-matched tests; regression-snapshot: skipped - no .atv/snapshots directory; scope-discovery: README.md - visible quality workflow must stop listing GHCP adapter as missing; scope-discovery: docs/context/operations/testing.md - testing operations must list implemented GHCP adapter; scope-check: forecast=3 changed=5 discovered=2 unexplained=0; proof: powershell -ExecutionPolicy Bypass -File scripts/skill-eval-run-ghcp.ps1 -FixtureId tiny-typo-fix -DryRun exit=0; proof: powershell -ExecutionPolicy Bypass -File scripts/skill-eval-run-ghcp.ps1 -FixtureId tiny-typo-fix exit=0 result=.atv/eval-runs/20260530-014242-tiny-typo-fix-ghcp/result.json score=0 issues; memory-impact: durable; areas=testing,eval-map"
  - id: slice-002
    title: "Wire adapter dry-runs into canonical checks"
    path: docs/plans/2026-05-30-002-tool-adapter-dry-run-kb-check-plan.md
    blockers: [slice-001]
    verification: functional
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-forecast: loaded 4 expected files + 0 convention-matched tests; scope-discovery: E:/all-the-vibes/.github/skills/kb-check/scripts/kb-check.ps1 - required ATV skill sync target; proof: kb-check -List showed skill-eval-ghcp-dry-run; proof: kb-check -All exit=0 including Codex and GHCP dry-runs; proof: skill-sync-report required issues=0; memory-impact: durable; areas=testing,quality-contract,sync"
  - id: slice-003
    title: "Add live cross-runtime corpus runner"
    path: docs/plans/2026-05-30-003-tool-live-cross-runtime-corpus-runner-plan.md
    blockers: [slice-001]
    verification: functional
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-forecast: loaded 3 expected files + 0 convention-matched tests; regression-snapshot: skipped - no .atv/snapshots directory; scope-discovery: README.md - visible quality workflow must mention explicit corpus runner; scope-discovery: docs/context/operations/testing.md - testing operations must document corpus dry-run/live boundary; scope-check: forecast=3 changed=5 discovered=2 unexplained=0; proof: powershell -ExecutionPolicy Bypass -File scripts/skill-eval-run-live-corpus.ps1 -FixtureId tiny-typo-fix -Runtime codex,ghcp -DryRun exit=0 results=2; proof: powershell -ExecutionPolicy Bypass -File scripts/skill-eval-run-live-corpus.ps1 -All -Runtime codex,ghcp -DryRun exit=0 results=16; memory-impact: durable; areas=testing,eval-map"
  - id: slice-004
    title: "Expand deterministic trace rule scoring"
    path: docs/plans/2026-05-30-004-tool-trace-rule-scoring-plan.md
    blockers: []
    verification: tdd
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-forecast: loaded 4 expected files + 0 convention-matched tests; regression-snapshot: skipped - no .atv/snapshots directory; scope-forecast-unused: evals/skill-eval/result.schema.json - trace_rules are scorer-only and not emitted by live adapters yet; scope-check: forecast=4 changed=5 discovered=0 unexplained=0; proof: powershell -ExecutionPolicy Bypass -File scripts/skill-eval.ps1 exit=0 selftests=7 issues=0; proof: kb-check -All exit=0; memory-impact: operational"
  - id: slice-005
    title: "Add transcript-derived claim verifier"
    path: docs/plans/2026-05-30-005-tool-transcript-claim-verifier-plan.md
    blockers: [slice-004]
    verification: tdd
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-forecast: loaded 4 expected files + 0 convention-matched tests; regression-snapshot: skipped - no .atv/snapshots directory; scope-discovery: README.md - visible quality workflow must mention claim verifier; scope-discovery: docs/context/operations/testing.md - testing operations must list claim verifier selftest; scope-discovery: docs/context/eval-map.md - eval map must remove transcript-claim gap; scope-check: forecast=4 changed=9 discovered=3 unexplained=0; proof: powershell -ExecutionPolicy Bypass -File scripts/skill-eval-claims.ps1 exit=0 cases=3 issues=0; proof: powershell -ExecutionPolicy Bypass -File scripts/skill-eval.ps1 exit=0 selftests=9 issues=0; memory-impact: durable; areas=testing,eval-map"
  - id: slice-006
    title: "Add output quality rubric scorer"
    path: docs/plans/2026-05-30-006-tool-output-quality-rubric-plan.md
    blockers: []
    verification: tdd
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: pending
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: "Rubric output is separate from deterministic route/proof/claim pass/fail."
  - id: slice-007
    title: "Add cost and regression reporting"
    path: docs/plans/2026-05-30-007-tool-cost-regression-report-plan.md
    blockers: [slice-003]
    verification: functional
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: pending
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: ""
  - id: slice-008
    title: "Add eval-map scaffold negative validation"
    path: docs/plans/2026-05-30-008-skill-eval-map-negative-validation-plan.md
    blockers: []
    verification: verification-only
    test_level: none
    functional_risk: none
    hitl: false
    status: pending
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: ""
    human_action: ""
    can_continue_other_slices: true
    notes: ""
---

# KB: Live Cross-Runtime Skill Eval Harness

## Origin

Brainstorm: `docs/brainstorms/2026-05-30-live-cross-runtime-skill-eval-harness-requirements.md`

## Slice Overview

| # | Slice | Blocked By | Verification | Test Level | HITL | Status |
|---|---|---|---|---|---|---|
| 1 | Add GHCP live skill eval adapter | - | functional | functional-cli | no | pending |
| 2 | Wire adapter dry-runs into canonical checks | slice-001 | functional | functional-cli | no | pending |
| 3 | Add live cross-runtime corpus runner | slice-001 | functional | functional-cli | no | pending |
| 4 | Expand deterministic trace rule scoring | - | tdd | functional-cli | no | pending |
| 5 | Add transcript-derived claim verifier | slice-004 | tdd | functional-cli | no | pending |
| 6 | Add output quality rubric scorer | - | tdd | functional-cli | no | pending |
| 7 | Add cost and regression reporting | slice-003 | functional | functional-cli | no | pending |
| 8 | Add eval-map scaffold negative validation | - | verification-only | none | no | pending |

## Assumptions

- Local Copilot CLI remains the first GHCP runtime because it is installed and
  documented for programmatic prompts.
- GHCP output schema enforcement is unavailable unless future `copilot help` or
  official docs expose a schema flag.
- Live model calls stay explicit and are not part of `kb-check -All`.
- Local JSON and Markdown artifacts remain the source of truth; dashboard
  integrations are exporter-only.

## Completion Criteria

- GHCP and Codex adapters both have dry-run coverage under `kb-check -All`.
- A live corpus command can run all current route fixtures for both runtimes.
- Deterministic scoring can fail route, trace, proof, structured claim, and
  transcript-derived false-claim cases.
- Output quality and cost/regression reports exist without replacing
  deterministic pass/fail gates.
- `docs/context/eval-map.md`, `docs/context/operations/testing.md`, and
  `todo.md` reflect the new truth.
