---
type: kb-manifest
kb_id: kb-2026-06-10-skill-bundle-hardening
brainstorm_path: direct-chat
created: 2026-06-10
status: reviewed
workflow_shape: "multi-stream-epic"
scope-verified-files:
  - .atv/kb-completions.txt
  - .github/agents/cli-agent-readiness-reviewer.agent.md
  - .github/agents/cli-readiness-reviewer.agent.md
  - cmd/kbcheck/manifest_contract.go
  - cmd/kbcheck/manifest_contract_test.go
  - cmd/kbcheck/release.go
  - cmd/kbcheck/review_reference_guard.go
  - cmd/kbcheck/review_reference_guard_test.go
  - config/skill-quality.json
  - docs/brainstorms/2026-06-10-h2-controlled-kb-experiment.md
  - docs/context/decisions/README.md
  - docs/context/decisions/cli-agent-readiness-reviewer-merge-2026-06-10.md
  - docs/context/decisions/hot-path-token-rent-audit-2026-06-10.md
  - docs/context/decisions/markdown-runtime-contract-2026-06-10.md
  - docs/context/decisions/plans-archive-policy-2026-06-10.md
  - docs/context/memory-maintenance.md
  - docs/handoffs/active/.gitkeep
  - docs/handoffs/done/.gitkeep
  - docs/handoffs/parked/.gitkeep
  - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
  - docs/plans/archive/
  - docs/solutions/workflow-issues/review-reference-closed-contract-2026-06-10.md
  - todo.md
  - todo-done.md
gate_ledger:
  - gate_id: plan-to-work
    owner_skill: kb-plan
    status: passed
    required_evidence:
      - "manifest path exists"
      - "all requested slices represented inline"
      - "DAG has no missing blockers or cycles"
      - "each slice has acceptance criteria, expected_files, verification, test_level, functional_risk"
      - "HITL classification is explicit"
    proof:
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
      - docs/context/decisions/hot-path-token-rent-audit-2026-06-10.md
      - docs/context/decisions/plans-archive-policy-2026-06-10.md
      - docs/context/decisions/cli-agent-readiness-reviewer-merge-2026-06-10.md
      - docs/brainstorms/2026-06-10-h2-controlled-kb-experiment.md
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "kb-work docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md"
  - gate_id: slice-slice-001-to-done
    owner_skill: kb-work
    status: passed
    required_evidence:
      - "rent tables recorded"
      - "extraction/deletion outcome recorded"
      - "allowlist reasons evidence-backed"
      - "skill-lint proof recorded"
      - "route-eval proof recorded"
      - "core proof recorded"
    proof:
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
      - config/skill-quality.json
      - docs/context/decisions/hot-path-token-rent-audit-2026-06-10.md
      - docs/context/memory-maintenance.md
      - .github/skills/kb-brainstorm/SKILL.md
      - .github/skills/kb-plan/SKILL.md
    proof_commands:
      - "go run ./cmd/kbcheck skill-lint"
      - "go run ./cmd/kbcheck route-eval"
      - "go run ./cmd/kbcheck core"
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "kb-work docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md"
  - gate_id: slice-slice-002-to-done
    owner_skill: kb-work
    status: passed
    required_evidence:
      - "sweep mode implemented"
      - "document-review references classified"
      - "unit tests pass"
      - "dummy duplicate negative proof recorded"
      - "core proof recorded"
    proof:
      - cmd/kbcheck/review_reference_guard.go
      - cmd/kbcheck/review_reference_guard_test.go
      - config/skill-quality.json
      - docs/context/decisions/review-reference-drift-guard-2026-06-10.md
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
    proof_commands:
      - "go test ./cmd/kbcheck"
      - "go run ./cmd/kbcheck review-reference-guard"
      - "dummy duplicate guard exit=1"
      - "go run ./cmd/kbcheck core"
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "kb-work docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md"
  - gate_id: slice-slice-003-to-skipped
    owner_skill: kb-work
    status: skipped
    required_evidence:
      - "GitHub workflow change intentionally omitted"
      - "local-release proof recorded"
      - "platform-proof signal remains open"
    proof:
      - cmd/kbcheck/release.go
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
      - docs/context/memory-maintenance.md
    proof_commands:
      - "go run ./cmd/kbcheck local-release"
      - "no GitHub Actions workflow change shipped in this push"
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "push branch without GitHub workflow changes"
  - gate_id: slice-slice-004-to-done
    owner_skill: kb-work
    status: passed
    required_evidence:
      - "decision docs live under docs/context/decisions"
      - "decision index updated"
      - "handoff directories are tracked"
      - "fresh-session layout matches tree"
    proof:
      - docs/context/decisions/README.md
      - docs/context/decisions/contributor-core-vs-release-sync-gates-2026-06-10.md
      - docs/context/decisions/review-reference-drift-guard-2026-06-10.md
      - docs/handoffs/active/.gitkeep
      - docs/handoffs/parked/.gitkeep
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "kb-work docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md"
  - gate_id: slice-slice-005-to-done
    owner_skill: kb-work
    status: passed
    required_evidence:
      - "archive rule recorded"
      - "before/after counts recorded"
      - "historical files moved"
      - "todo pointers updated"
      - "dangling reference check passed"
    proof:
      - docs/context/decisions/plans-archive-policy-2026-06-10.md
      - docs/plans/archive/
      - todo.md
      - todo-done.md
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
    proof_commands:
      - "plans_root_before=100 plans_moved=89 plans_root_after=11"
      - "dangling_root_plan_refs=0"
      - "go run ./cmd/kbcheck core"
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "kb-work docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md"
  - gate_id: slice-slice-006-to-done
    owner_skill: kb-work
    status: passed
    required_evidence:
      - "human approval recorded"
      - "unique content folded into survivor"
      - "approved agent deleted"
      - "minimality before/after recorded"
      - "other candidates remain parked"
    proof:
      - .github/agents/cli-readiness-reviewer.agent.md
      - docs/context/decisions/cli-agent-readiness-reviewer-merge-2026-06-10.md
      - docs/context/memory-maintenance.md
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
      - todo.md
    proof_commands:
      - "go run ./cmd/kbcheck minimality before: agents=52 cold-storage=12 trim-candidate=1"
      - "go run ./cmd/kbcheck minimality after: agents=51 cold-storage=11 trim-candidate=0"
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "kb-work docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md"
  - gate_id: slice-slice-007-to-parked
    owner_skill: kb-work
    status: parked
    required_evidence:
      - "draft brainstorm exists"
      - "no harness changes made"
      - "parked for human review"
    proof:
      - docs/brainstorms/2026-06-10-h2-controlled-kb-experiment.md
      - todo.md
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "human review of parked brainstorm"
  - gate_id: slice-slice-008-to-done
    owner_skill: kb-work
    status: passed
    required_evidence:
      - "deterministic manifest phase/gate rules moved into kbcheck"
      - "unit tests cover missing done gates and invalid passed gates"
      - "active manifest validates"
      - "decision record captures markdown/runtime boundary"
    proof:
      - cmd/kbcheck/manifest_contract.go
      - cmd/kbcheck/manifest_contract_test.go
      - docs/context/decisions/markdown-runtime-contract-2026-06-10.md
      - docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md
    proof_commands:
      - "go test ./cmd/kbcheck"
      - "go run ./cmd/kbcheck manifest-contract --manifest docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md"
      - "go run ./cmd/kbcheck gate-ledger --manifest docs/plans/2026-06-10-011-kb-skill-bundle-hardening-manifest.md --gate slice-slice-008-to-done"
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "push branch and verify GitHub Actions run"
slices:
  - id: slice-001
    title: "Hot-path token-rent audit"
    status: done
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    notes: "No extraction/deletion: rent table classified inline sections as always-path safety/routing/gate contracts; config allowlist updated with evidence-backed reasons."
  - id: slice-002
    title: "Review-reference guard sweep mode"
    status: done
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    notes: "Sweep mode already implemented; negative dummy duplicate proof added for this run."
  - id: slice-003
    title: "CI local-release workflow deferred"
    status: skipped
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    notes: "GitHub workflow mutation omitted by user decision; local-release remains locally green and platform-proof stays open."
  - id: slice-004
    title: "Memory layout honesty"
    status: done
    verification: verification-only
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    notes: "Decision docs are under docs/context/decisions and handoff dirs are tracked with .gitkeep."
  - id: slice-005
    title: "Plans archive policy"
    status: done
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    notes: "Archived 89 historical root plan files; dangling root reference check passed."
  - id: slice-006
    title: "HITL first cold-storage approval"
    status: done
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: true
    notes: "User approved only cli-agent-readiness-reviewer merge; all other unproven agents remain parked."
  - id: slice-007
    title: "Draft H2 controlled experiment brainstorm"
    status: parked
    verification: verification-only
    test_level: none
    functional_risk: none
    hitl: true
    notes: "Parked draft only; no harness changes."
  - id: slice-008
    title: "Markdown-to-runtime contract extraction"
    status: done
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    notes: "Moved deterministic manifest phase/gate proof rules into kbcheck; hot-path prose should now delegate these checks instead of restating them."
---

# KB: Skill Bundle Hardening

## Rent Tables

### kb-brainstorm

| Section | Classification | Consuming branch |
|---|---|---|
| Header/current-year/file-reference contract | ALWAYS | Every generated brainstorm document and handoff |
| When to Pick | ALWAYS | Route validation before choosing brainstorm vs research/chat |
| Core Principles | ALWAYS | All brainstorm decisions and artifact sizing |
| Interaction Rules | ALWAYS | Every user-question turn |
| Question Gate | ALWAYS | Required before any plan handoff |
| Token Budget | ALWAYS | Artifact and response sizing throughout |
| Intellectual Honesty | ALWAYS | Every challenge/pushback path |
| Output Guidance | ALWAYS | Every generated brainstorm artifact |
| Feature Description input rule | ALWAYS | Every invocation start |
| Phase 0 Resume/Assess/Route | ALWAYS | Startup branch selection and stale-work avoidance |
| Phase 1 Topic Intake | ALWAYS | Topic identity confirmation or skip decision |
| Phase 2 Repo Context Scan | ALWAYS | Required local orientation before questions |
| Phase 3 Research Decision and sub-branches | ALWAYS | Must decide whether external research fires and how deep |
| Phase 4 Orientation Brief | ALWAYS | Alignment before Q&A or explicit skip |
| Phase 5 Product Pressure Test | ALWAYS | Scope/risk pressure test or skip decision |
| Phase 6 Targeted Q&A | ALWAYS | Requirements closure and question discipline |
| Phase 7 Approaches | ALWAYS | Recommendation path when alternatives remain |
| Phase 8 Capture Requirements | ALWAYS | Decide/write/skip durable requirements |
| Phase 9 Document Review | ALWAYS | Review gate when an artifact exists |
| Phase 10 Handoff | ALWAYS | Prevent phase skipping into work |
| Quality Checks / Integration | ALWAYS | Self-audit and next-lane contract |

Outcome: no extraction or deletion for judgment prose. Deterministic phase/gate proof rules are TOOL-class and now begin moving into `kbcheck manifest-contract` / `kbcheck gate-ledger`.

### kb-plan

| Section | Classification | Consuming branch |
|---|---|---|
| Quick Start / Interaction Method | ALWAYS | Every plan invocation and execution-intent decision |
| Input modes | ALWAYS | Source normalization for empty/path/handoff/description |
| Core Rules | ALWAYS | Slice validity, verification, and test-level policy |
| Process 1 Understand Source | ALWAYS | Planning gate and blocker classification |
| Process 1.5 Research | ALWAYS | Decide whether local/external research is needed |
| Draft / Validate Slices | ALWAYS | Every manifest DAG and slice forecast |
| Generate Plan Files templates | ALWAYS | Manifest contract and inline/standard slice shape |
| Update Todo and Handoffs | ALWAYS | Board synchronization and restart recovery |
| Validate Output / Optional Commit | ALWAYS | Gate closure and explicit no-commit default |
| Success / Integration | ALWAYS | Handoff to work and protected-oracle contract |

Outcome: no extraction or deletion for judgment prose. Manifest phase/gate proof rules are TOOL-class and now begin moving into `kbcheck manifest-contract` / `kbcheck gate-ledger`.

### kb-work

| Section | Classification | Consuming branch |
|---|---|---|
| Quick Start / Input / Continuous Loop | ALWAYS | Every work invocation and terminal-state decision |
| Pre-flight | ALWAYS | Gate, DAG, landmine, board, and worktree checks |
| Status table / Board Sync | ALWAYS | Every slice state transition |
| Ready-set ordering | ALWAYS | Every slice scheduling pass |
| Execution Loop / continuous rule | ALWAYS | Every slice execution pass |
| HITL handling | ALWAYS | Must classify every `hitl` flag before proceeding |
| Deepen / Test-level / Regression snapshot | ALWAYS | Every slice proof obligation or skip decision |
| Scope forecast / Execute / Oracle / System-wide / Diff-scope | ALWAYS | Every implementation and scope check |
| Destructive guard / QA / Figma UI branch | ALWAYS | Safety checks must be available before branch decision |
| Verify and Update | ALWAYS | Every completed slice |
| Completion / Failure / Resume / Success / Integration | ALWAYS | Terminal state, proof, and kb-complete transition |

Outcome: no extraction or deletion for judgment prose. Slice terminal-state proof rules are TOOL-class and now begin moving into `kbcheck manifest-contract` / `kbcheck gate-ledger`.

## Slice Notes

- Slice 1 closed the bloat-risk signal by evidence-backed allowlisting, not shrinking.
- Slice 2 was already implemented and received the required negative dummy proof in this run.
- Slice 3 is intentionally skipped for this push: no GitHub workflow mutation ships; platform-proof remains open until a credentialed workflow update is explicitly wanted.
- Slice 4 closed decision-layout honesty and tracked handoff dirs.
- Slice 5 archived historical plans by month and rewrote references.
- Slice 6 executed only the approved deletion.
- Slice 7 is parked and draft-only.
- Slice 8 corrected the rent model: deterministic workflow rules should move to Go; inline prose is for judgment, scope, escalation, and tradeoffs.
