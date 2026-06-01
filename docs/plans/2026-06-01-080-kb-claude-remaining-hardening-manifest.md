---
type: kb-manifest
kb_id: kb-2026-06-01-claude-remaining-hardening
brainstorm_path: docs/context/epics/claude-remaining-hardening.md
created: 2026-06-01
status: completed
workflow_shape: "multi-stream-epic"
scope-verified-files:
  - docs/context/epics/claude-remaining-hardening.md
  - docs/brainstorms/2026-06-01-release-confidence-gate-requirements.md
  - docs/brainstorms/2026-06-01-skill-surface-minimality-requirements.md
  - docs/brainstorms/2026-06-01-cross-platform-tooling-requirements.md
  - docs/brainstorms/2026-06-01-upstream-selective-sync-requirements.md
  - docs/plans/2026-06-01-080-kb-claude-remaining-hardening-manifest.md
  - docs/plans/2026-06-01-081-tool-release-confidence-gate-plan.md
  - docs/plans/2026-06-01-082-tool-skill-surface-minimality-report-plan.md
  - docs/plans/2026-06-01-083-tool-go-core-gate-wrapper-plan.md
  - docs/plans/2026-06-01-084-tool-upstream-delta-report-plan.md
  - docs/plans/2026-06-01-085-cold-trim-deletion-queue-plan.md
slices:
  - id: slice-081
    title: "Add release confidence gate profiles"
    path: docs/plans/2026-06-01-081-tool-release-confidence-gate-plan.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: completed
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Create local-release/live-release gate profiles that compose existing checks and report pass/fail/skipped honestly."
    human_action: ""
    can_continue_other_slices: true
    notes: "Completed: added local/live release profiles, selftest, docs, and kb-check wiring. Proof: kb-release-gate-selftest, kb-check -All, kb-release-gate local-release."
    protected_oracles:
      - path: "scripts/kb-release-gate-selftest.ps1"
        role: "release gate behavior oracle"
        sha256: "0286ffc32dd540e46b5d38dba91e59cc90d6d8decb2a22194b3eb7c903c305f0"
        update_policy: "requires explicit plan update"
  - id: slice-082
    title: "Classify skill and reviewer-agent minimality"
    path: docs/plans/2026-06-01-082-tool-skill-surface-minimality-report-plan.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: completed
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Add a report that classifies agents/skills as required, conditional, unproven, or unused without deleting anything."
    human_action: ""
    can_continue_other_slices: true
    notes: "Completed: added static minimality report and cold-storage candidate output. Slice-085 later added protected classification before any deletion."
    protected_oracles:
      - path: "scripts/skill-surface-minimality-selftest.ps1"
        role: "minimality report behavior oracle"
        sha256: "d87f43751d408058923517492c5a595080734a40c02786e3faa238c9404c4d4e"
        update_policy: "requires explicit plan update"
  - id: slice-083
    title: "Add Go core-gate wrapper"
    path: docs/plans/2026-06-01-083-tool-go-core-gate-wrapper-plan.md
    blockers: [slice-081]
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: completed
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Completed: thin Go wrapper delegates core/local-release/live-release to existing PowerShell gates."
    human_action: ""
    can_continue_other_slices: true
    notes: "Completed: added go.mod plus cmd/kbcheck CLI and tests. Proof: go test ./..., go build ./cmd/kbcheck, go run ./cmd/kbcheck help, go run ./cmd/kbcheck core --dry-run, go run ./cmd/kbcheck local-release --json --dry-run, go run ./cmd/kbcheck local-release."
    protected_oracles:
      - path: "cmd/kbcheck/main_test.go"
        role: "Go wrapper CLI behavior oracle"
        sha256: "7d4eb43f0a9eaae6c8993ec029e9716aa11aeffc5f58dcdda768cbb6f7b0f7a9"
        update_policy: "requires explicit plan update"
  - id: slice-084
    title: "Add read-only ATV upstream delta report"
    path: docs/plans/2026-06-01-084-tool-upstream-delta-report-plan.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: completed
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Create a read-only upstream delta report that categorizes ATV changes without applying them."
    human_action: ""
    can_continue_other_slices: true
    notes: "Completed: added read-only upstream delta classifier, config, selftest, and docs. No apply mode."
    protected_oracles:
      - path: "scripts/atv-upstream-delta-selftest.ps1"
        role: "upstream delta classification oracle"
        sha256: "eca55c91fe7779bb786aa3d19680f07839db3eb2aa70b136bbb161547f167848"
        update_policy: "requires explicit plan update"
  - id: slice-085
    title: "Park trim and deletion execution queue"
    path: docs/plans/2026-06-01-085-cold-trim-deletion-queue-plan.md
    blockers: [slice-082]
    verification: verification-only
    test_level: none
    functional_risk: none
    hitl: false
    status: completed
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Completed: protected repo-policy dependencies from deletion candidates; no deletions were justified by static evidence."
    human_action: ""
    can_continue_other_slices: true
    notes: "Completed: added protected minimality classification and selftest. Cold-storage candidates dropped from 16 to 12; remaining candidates require runtime usage proof or focused trimming before deletion."
    protected_oracles: []
---

# KB: Claude Remaining Hardening

## Origin

Epic: `docs/context/epics/claude-remaining-hardening.md`

Brainstorms:

- `docs/brainstorms/2026-06-01-release-confidence-gate-requirements.md`
- `docs/brainstorms/2026-06-01-skill-surface-minimality-requirements.md`
- `docs/brainstorms/2026-06-01-cross-platform-tooling-requirements.md`
- `docs/brainstorms/2026-06-01-upstream-selective-sync-requirements.md`

## Workflow Shape

`multi-stream-epic` - the work touches release proof, deletion safety, Go
tooling, upstream drift policy, docs, and repo memory.

## Slice Overview

| # | Slice | Blocked By | Verification | HITL | Status |
|---|---|---|---|---|---|
| 1 | Add release confidence gate profiles | - | integration | no | completed |
| 2 | Classify skill and reviewer-agent minimality | - | integration | no | completed |
| 3 | Add Go core-gate wrapper | slice-081 | integration | no | completed |
| 4 | Add read-only ATV upstream delta report | - | integration | no | completed |
| 5 | Park trim and deletion execution queue | slice-082 | verification-only | no | completed |

## Assumptions

- `kb-check -All` remains the default deterministic gate.
- Live Codex/GHCP evals are explicit release-gate options, not default local
  checks.
- Go wrapper work starts small and shells/composes existing checks before any
  full harness port.
- Upstream delta reporting is read-only in this pass.

## Release Queue

Runnable now:

- None. All slices in this manifest are completed.

Parked:

- None in this manifest. Remaining cold-storage candidates require a new
  runtime-usage or focused-trim plan before deletion.

## Final Verification Target

- `.\.github\skills\kb-check\scripts\kb-check.ps1 -All`
- Release gate local profile
- Upstream delta selftest
- `scripts\skill-sync-report.ps1`
- `git diff --check`

## Completion Evidence

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kb-release-gate-selftest.ps1` passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\skill-surface-minimality-selftest.ps1` passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\atv-upstream-delta-selftest.ps1` passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .github\skills\kb-check\scripts\kb-check.ps1 -All` passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kb-release-gate.ps1 -Profile local-release` passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\skill-sync-report.ps1` passed.
- `git diff --check` passed with line-ending warnings only.
