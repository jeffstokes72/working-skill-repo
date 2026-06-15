---
kb_id: kb-2026-06-01-claude-remaining-hardening
slice_id: slice-083
title: "Add Go core-gate wrapper"
blockers: [slice-081]
verification: integration
test_level: functional-cli
functional_risk: medium
hitl: false
expected_files:
  - path: go.mod
    op: create
    scope: "Initialize a minimal Go module for the cross-platform gate wrapper if no module exists."
  - path: cmd/kbcheck/main.go
    op: create
    scope: "Implement a small CLI that runs local release/core gate commands."
  - path: cmd/kbcheck/main_test.go
    op: create
    scope: "Test argument parsing and command construction without running expensive gates."
  - path: README.md
    op: edit
    scope: "Document Go wrapper build/run commands and PowerShell fallback."
  - path: docs/context/PROJECT.md
    op: edit
    scope: "Update platform/tooling map after wrapper exists."
protected_oracles:
  - path: cmd/kbcheck/main_test.go
    role: "Go wrapper CLI behavior oracle"
    sha256: "7d4eb43f0a9eaae6c8993ec029e9716aa11aeffc5f58dcdda768cbb6f7b0f7a9"
    update_policy: "requires explicit plan update"
status: completed
owner: agent
blocked_reason: ""
resume_when: ""
next_agent_action: "Completed: thin Go wrapper delegates core/local-release/live-release to existing PowerShell gates."
human_action: ""
can_continue_other_slices: true
---

# Slice 083: Go Core-Gate Wrapper

## What Was Built

A minimal Go CLI wrapper for the core/release gate. The wrapper is thin: it
provides a cross-platform entry point and delegates to the existing PowerShell
gate implementation. It is not a full harness rewrite.

## Acceptance Criteria

- `go test ./...` passes when Go is available.
- The wrapper exposes local-release/core check commands with clear help text.
- The wrapper preserves PowerShell behavior underneath initially.
- Missing PowerShell or missing scripts produce clear errors.
- README says this is a wrapper, not proof of a full non-PowerShell harness port.

## Test Scenarios

- Run `go test ./...`.
- Build with `go build ./cmd/kbcheck`.
- Run the wrapper help command.
- Run the wrapper against the local-release gate if slice-081 is complete.

## Completion Evidence

- `go test ./...` passed.
- `go build ./cmd/kbcheck` passed.
- `go run ./cmd/kbcheck help` passed.
- `go run ./cmd/kbcheck core --dry-run` passed.
- `go run ./cmd/kbcheck local-release --json --dry-run` passed.
- `go run ./cmd/kbcheck local-release` passed.
- Protected oracle: `cmd/kbcheck/main_test.go`
  `sha256=7d4eb43f0a9eaae6c8993ec029e9716aa11aeffc5f58dcdda768cbb6f7b0f7a9`.

## Scope Boundary

- Do not rewrite all PowerShell scripts in Go.
- Do not move the wrapper into ATV in this slice.
- Do not claim stock macOS/Linux support beyond what the wrapper actually runs.

## Dependencies

- Depends on `slice-081` because the wrapper should call the release gate rather
  than inventing a second gate contract.
