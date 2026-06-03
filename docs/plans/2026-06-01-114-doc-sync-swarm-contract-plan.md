---
kb_id: kb-2026-06-01-kb-work-swarm-ready-set
slice_id: slice-114
title: "Propagate swarm contract and prove release"
blockers: [slice-112, slice-113]
verification: integration
test_level: functional-cli
functional_risk: medium
hitl: false
expected_files:
  - path: README.md
    op: edit
    scope: "Mention bounded parallel KB work only if the proof tooling lands."
  - path: docs/context/PROJECT.md
    op: edit
    scope: "Refresh known sharp edges or current workflow notes if swarm semantics become durable."
  - path: todo.md
    op: edit
    scope: "Mark this manifest complete or record any parked follow-up."
  - path: <atv-repo>\.github\skills\kb-work\SKILL.md
    op: edit
    scope: "Sync approved kb-work copy after repo changes."
  - path: ~/.codex/skills\kb-work\SKILL.md
    op: edit
    scope: "Sync approved kb-work copy after repo changes."
protected_oracles: []
status: done
---

# Slice 114: Propagate Swarm Contract And Prove Release

## What To Build

After the swarm contract and proof scripts exist, propagate the changed skill to
global and ATV tracked roots, update memory/docs, and run the release gate.

## Acceptance Criteria

- `kb-work` copies match across working repo, Codex global, Copilot global,
  agents global, ATV `.github`, ATV scaffold, and ATV plugin roots.
- Docs do not overclaim enforcement beyond the implemented ready-set and
  overlap proof.
- `todo.md` points to this manifest while active and records the result when
  done.
- `go run .\cmd\kbcheck local-release --json` passes.

## Test Scenarios

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\skill-sync-report.ps1`
- `go run .\cmd\kbcheck local-release --json`
- `git diff --check`

## Scope Boundary

- Do not commit unless the user asks.
- Do not sync unrelated ATV upstream changes.
- Do not claim macOS/Linux proof from Windows-only runs.

## Completion Proof

- Synced `kb-work` to Codex global, Copilot global, shared agents global, ATV
  `.github`, ATV scaffold, and ATV plugin roots.
- Updated README, project memory, and operations docs for bounded swarming.
- `go run .\cmd\kbcheck local-release --json` exited 0 with required failures
  0 and optional failures 0.
- Working repo and ATV `git diff --check` exited 0.
