---
type: kb-manifest
kb_id: kb-2026-05-31-marketplace-promotion-cli
brainstorm_path: docs/brainstorms/2026-05-31-marketplace-promotion-cli-requirements.md
created: 2026-05-31
status: completed
workflow_shape: "skill-bundle-change"
scope-verified-files:
  - docs/brainstorms/2026-05-31-marketplace-promotion-cli-requirements.md
  - docs/plans/2026-05-31-060-kb-marketplace-promotion-cli-manifest.md
  - docs/plans/2026-05-31-061-tool-marketplace-promotion-cli-plan.md
  - docs/plans/2026-05-31-062-tool-marketplace-promotion-selftest-plan.md
  - docs/plans/2026-05-31-063-doc-marketplace-promotion-cli-plan.md
  - scripts/promote-marketplace-skill.ps1
  - scripts/promote-marketplace-skill-selftest.ps1
  - .github/skills/kb-check/scripts/kb-check.ps1
  - .github/skills/kb-plan/SKILL.md
  - .github/skills/kb-work/SKILL.md
  - README.md
  - docs/context/architecture/private-skill-marketplace.md
  - docs/context/operations/testing.md
  - todo.md
  - todo-done.md
slices:
  - id: slice-061
    title: "Build single-command marketplace promotion"
    path: docs/plans/2026-05-31-061-tool-marketplace-promotion-cli-plan.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Create promote-marketplace-skill.ps1 with validation, copy, hash pin, sync, firebreak, and summary output."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=1 changed=1 discovered=0 unexplained=0; proof: PowerShell parser accepted scripts/promote-marketplace-skill.ps1; memory-impact: durable; areas=marketplace-promotion-cli; refresh=pending"
    protected_oracles: []
  - id: slice-062
    title: "Add promotion selftest to kb-check"
    path: docs/plans/2026-05-31-062-tool-marketplace-promotion-selftest-plan.md
    blockers: [slice-061]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Create selftest using temp marketplace/config and wire it into kb-check -All."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=2 changed=2 discovered=0 unexplained=0; proof: promote-marketplace-skill-selftest passed; kb-check -List includes marketplace-promotion-selftest; memory-impact: durable; areas=kb-check-marketplace-promotion; refresh=pending"
    protected_oracles: []
  - id: slice-063
    title: "Document the safe fast path"
    path: docs/plans/2026-05-31-063-doc-marketplace-promotion-cli-plan.md
    blockers: [slice-062]
    verification: verification-only
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    owner: agent
    blocked_reason: ""
    resume_when: ""
    next_agent_action: "Update README and project memory so future agents use the script instead of manual direct installs."
    human_action: ""
    can_continue_other_slices: true
    notes: "scope-check: forecast=5 changed=5 discovered=2 unexplained=0; scope-discovery: .github/skills/kb-plan/SKILL.md and .github/skills/kb-work/SKILL.md - required sync drift had useful active-landmine guidance in globals, merged back to source; proof: promote-marketplace-skill-selftest passed; kb-check -All passed with 0 required sync issues; git diff --check passed with line-ending warnings only; memory-impact: durable; areas=marketplace-promotion-cli,kb-check,skill-sync; refresh=done"
    protected_oracles: []
---

# KB: Marketplace Promotion CLI

## Origin

Brainstorm: `docs/brainstorms/2026-05-31-marketplace-promotion-cli-requirements.md`

## Workflow Shape

`skill-bundle-change` - adds a local workflow script, deterministic selftest,
and docs/memory for private marketplace promotion.

## Slice Overview

| # | Slice | Blocked By | Verification | HITL | Status |
|---|---|---|---|---|---|
| 1 | Build single-command marketplace promotion | - | integration | no | done |
| 2 | Add promotion selftest to kb-check | slice-061 | integration | no | done |
| 3 | Document the safe fast path | slice-062 | verification-only | no | done |

## Final Proof

- `scripts/promote-marketplace-skill-selftest.ps1` passed.
- `.\.github\skills\kb-check\scripts\kb-check.ps1 -List` includes `marketplace-promotion-selftest`.
- `.\.github\skills\kb-check\scripts\kb-check.ps1 -All` passed.
- `scripts/skill-sync-report.ps1` reported 0 required sync issues.
- `git diff --check` passed for the working repo and ATV, with line-ending warnings only.
