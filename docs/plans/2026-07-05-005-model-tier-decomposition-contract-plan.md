---
kb_id: kb-2026-07-05-phoenix-proof-spine-merge
slice_id: slice-005
title: "Add model-tier decomposition contract"
blockers: []
verification: integration
test_level: integration
functional_risk: narrow
model_tier: large
tier_reason: "This changes planning policy and delegation safety for future agents."
escalate_to_large_when:
  - "always large for policy authoring; later classification tasks may use small/mini models"
hitl: false
expected_files:
  - path: .github/skills/kb-plan/SKILL.md
    op: edit
    scope: "require model_tier, tier_reason, and escalation rules in manifest and slice plans"
  - path: .github/skills/kb-work/SKILL.md
    op: edit
    scope: "consume model_tier for subagent/delegation selection without weakening proof"
  - path: .github/skills/kb-functional-test/SKILL.md
    op: edit
    scope: "align existing mini-model classification guidance with the new tier contract"
  - path: docs/context/architecture/kb-workflow.md
    op: edit
    scope: "document model-tier routing and proof separation"
  - path: cmd/kbcheck/manifest_contract.go
    op: edit
    scope: "optional validation that new manifests include model_tier fields"
  - path: cmd/kbcheck/manifest_contract_test.go
    op: edit
    scope: "optional fixtures for missing/invalid model_tier"
protected_oracles: []
status: pending
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Add model-tier fields to plan contracts and deterministic manifest checks if practical."
human_action: ""
can_continue_other_slices: true
---

# Slice 005 - model-tier decomposition contract

## What To Build

Make KB decomposition answer "who can run this slice safely" in addition to
"what should be built."

Add required fields to new manifests and slice plans:

- `model_tier`: `tiny`, `small`, `medium`, or `large`;
- `tier_reason`: why this tier is enough;
- `escalate_to_large_when`: concrete signals that require escalation;
- optional `delegate_ok`: whether a subagent may execute independently.

## Tier Contract

| Tier | Safe Work | Must Escalate |
|---|---|---|
| `tiny` | deterministic transforms, path inventories, hash checks, table updates, status/diff summaries | any code design, ambiguous requirement, test failure diagnosis |
| `small` | test-level/risk classification, fixture generation, log summaries, boilerplate docs, narrow patch with fixed oracle | architecture, auth/security, complex UI, flaky async, repeated failures |
| `medium` | ordinary implementation with clear files, tests, and acceptance criteria | cross-workflow policy, destructive actions, unclear ownership, high blast radius |
| `large` | decomposition, architecture, security/destructive risk, long-context conflicts, terminal P0/P1 decisions | no automatic downgrade; split into smaller slices only after policy is clear |

Current examples checked on 2026-07-05:

- Large: Codex `gpt-5.5`; Claude Fable/Opus-class.
- Medium: Claude Sonnet-class or strong coding model equivalents.
- Small: Codex `gpt-5.4-mini`; Claude Haiku-class.
- Tiny: fastest local/tiny model or no model when a script can do it.

Do not hardcode a provider's marketing name as a permanent category. A future
`ds4` or similar model belongs in the tier it proves it can satisfy on this
repo's fixtures.

## Acceptance Criteria

- `kb-plan` requires `model_tier` and escalation fields in generated plans.
- `kb-work` treats the model tier as delegation guidance, not proof.
- `kb-functional-test` still allows small/mini models for bounded test-level
  classification.
- Missing or invalid tiers are caught by a deterministic check if the manifest
  parser can support it cheaply.

## Test Scenarios

- Valid manifest with all four tier types passes contract validation.
- Missing `model_tier` fails contract validation if the validator is added.
- A small-model slice with architecture/security escalation terms is accepted.
- A small-model slice claiming final proof by model judgment is rejected by text
  guidance or validator.

## Scope Boundary

This does not implement a live model router. It records safe delegation policy
and leaves actual provider selection to the host's current model config.

## Verification

Run:

```shell
go test ./cmd/kbcheck/...
go run ./cmd/kbcheck skill-lint
go run ./cmd/kbcheck core
```
