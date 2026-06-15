---
kb_id: kb-2026-06-01-claude-remaining-hardening
slice_id: slice-081
title: "Add release confidence gate profiles"
blockers: []
verification: integration
test_level: functional-cli
functional_risk: medium
hitl: false
expected_files:
  - path: scripts/kb-release-gate.ps1
    op: create
    scope: "Compose local-release and live-release proof profiles with honest pass/fail/skipped reporting."
  - path: scripts/kb-release-gate-selftest.ps1
    op: create
    scope: "Selftest release gate profile selection and skipped-live reporting."
  - path: .github/skills/kb-check/scripts/kb-check.ps1
    op: edit
    scope: "Wire release gate selftest into the canonical All gate if appropriate."
  - path: README.md
    op: edit
    scope: "Document local-release vs live-release usage before global sync."
  - path: docs/context/operations/testing.md
    op: edit
    scope: "Add release gate interpretation notes."
protected_oracles:
  - path: scripts/kb-release-gate-selftest.ps1
    role: "release gate behavior oracle"
    sha256: "0286ffc32dd540e46b5d38dba91e59cc90d6d8decb2a22194b3eb7c903c305f0"
    update_policy: "requires explicit plan update"
status: completed
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Completed. Maintain the release gate as the pre-sync proof surface."
human_action: ""
can_continue_other_slices: true
---

# Slice 081: Release Confidence Gate Profiles

## What To Build

Add an explicit release gate command with two profiles:

- `local-release`: deterministic proof suitable before syncing globals.
- `live-release`: explicit live Codex/GHCP evals when authenticated CLIs exist.

The gate must distinguish `passed`, `failed`, and `skipped-explicit`. A release
run with skipped live evals must not imply full live-model verification.

## Acceptance Criteria

- `scripts/kb-release-gate.ps1 -Profile local-release` runs deterministic local
  proof and exits nonzero on required failures.
- `scripts/kb-release-gate.ps1 -Profile live-release` attempts live-eval proof
  only when explicitly selected and reports unavailable/auth-missing surfaces as
  `skipped-explicit`.
- Output shows observed proof vs self-reported/model-reported proof where
  relevant.
- Selftest proves profile selection, skip labeling, and failure propagation.
- Docs tell the maintainer which command to run before global sync.

## Test Scenarios

- Run `powershell -ExecutionPolicy Bypass -File scripts/kb-release-gate-selftest.ps1`.
- Run `powershell -ExecutionPolicy Bypass -File scripts/kb-release-gate.ps1 -Profile local-release`.
- Run `.\.github\skills\kb-check\scripts\kb-check.ps1 -All`.

## Scope Boundary

- Do not make live model calls part of default `kb-check -All`.
- Do not implement syscall/file-read tracing.
- Do not sync globals in this slice.

## Dependencies

None.
