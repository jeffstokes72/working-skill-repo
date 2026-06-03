---
date: 2026-06-01
topic: cross-platform-tooling
brainstorm_style: kb-brainstorm
---

# Cross-Platform Tooling

## Problem Frame

The repo now honestly says it is PowerShell-first with a PowerShell 7 path, but
Claude's portability criticism remains true if "cross-platform" means stock
macOS/Linux without PowerShell. This stream decides whether to build real
non-PowerShell tooling or keep the claim scoped to `pwsh`.

## Research Summary

**Findings that shaped requirements:**
- `README.md` says PowerShell-first, PowerShell 7 cross-platform path, and
  Node/Python port remains future work.
- `scripts/powershell-helpers.ps1` centralizes PowerShell invocation.
- `kb-check.ps1` and harness scripts are `.ps1` today.
- Local ATV uses Go for its installer/CLI surface: `<atv-repo>\go.mod`,
  `main.go`, `cmd/*`, and Go tests.

**Confidence:** High - local toolchain is visibly PowerShell-first.

## Requirements

**Support Claim**
- R1. The README and project memory must not imply stock macOS/Linux support
  unless non-PowerShell scripts exist.
- R2. If true cross-platform support is in scope, provide a non-PowerShell entry
  point for the core quality gate.
- R2a. If a real cross-platform CLI is chosen later, prefer Go over Node/Python
  unless planning finds a concrete reason not to, because ATV already uses Go.

**Port Scope**
- R3. The first non-PowerShell path must cover the highest-value release/local
  checks before lower-value helper scripts.
- R4. The PowerShell path must remain supported during any port.
- R5. Cross-platform scripts must produce comparable pass/fail semantics, not a
  weaker "best effort" report.

## Success Criteria

- Users can tell exactly what platform/tooling is required.
- If ported, one non-Windows command can run the core gate without PowerShell.

## Scope Boundaries

- Do not port every helper script unless the first non-PowerShell core gate
  proves value.
- Do not break the current Windows/PowerShell workflow.

## Key Decisions

- Honesty is already acceptable if PowerShell 7 is the stated requirement.
  Evidence: README now states this clearly.
- Cross-platform implementation is parked for later. When it is promoted, the
  preferred target is a Go core-gate wrapper, not Node/Python and not a full
  harness rewrite. ATV already uses Go for its CLI/installer surface, so Go is
  the better ecosystem fit.

## Dependencies / Assumptions

- Assumption: the active maintainer is on Windows, so portability is not blocking
  personal use.

## Alternatives Considered

- Full Node/Python port now: high carrying cost unless non-Windows users are
  expected soon.
- Go wrapper/CLI later: likely better ecosystem fit than Node/Python because ATV
  is already Go-based.
- Documentation-only: acceptable if `pwsh` is the real support target.

## Slice Candidates (advisory for /kb-plan)

- Portability wording audit - remove or tighten any overclaim.
- Parked Go core gate wrapper - later wrapper that invokes the existing core
  checks through a cross-platform CLI surface while preserving PowerShell
  behavior underneath initially.
- Cross-platform selftest - when promoted, run the Go wrapper on Windows and
  document macOS/Linux expected setup.

## Outstanding Questions

### Resolve Before Planning

- None.

### Deferred to Planning

- [Affects R2][Technical] Decide whether any Go wrapper should live in this repo
  or in ATV.

## Next Steps

-> parked until the user promotes cross-platform implementation
