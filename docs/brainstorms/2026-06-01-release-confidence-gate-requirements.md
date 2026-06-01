---
date: 2026-06-01
topic: release-confidence-gate
brainstorm_style: kb-brainstorm
---

# Release Confidence Gate

## Problem Frame

The default `kb-check -All` is deterministic and fast enough for normal work,
but Claude's remaining criticism is about release confidence: live evals are
manual, observed trace is only active when wrapped, and the final "safe to sync
globals" question is still partly procedural.

The affected user is the repo maintainer before copying or committing global
skill changes. The gate should answer: "Can I release these globals and go back
to real project work without hidden proof gaps?"

## Research Summary

**Findings that shaped requirements:**
- `todo.md` records deterministic scoring, observed trace scoring, dry-run live
  adapters, and explicit live model calls outside `kb-check -All`.
- `evals/skill-eval/README.md` documents `trace` as model-reported intent and
  `observed_trace` as externally captured safety evidence.
- `README.md` already separates dry-run gate coverage from explicit live evals.

**Confidence:** High - local proof surfaces are implemented and documented.

## Requirements

**Release Gate Profile**
- R1. Provide one explicit command/profile for "release globals" proof that is
  separate from default `kb-check -All`.
- R2. The release gate must run deterministic checks, sync drift, observed trace
  wrapper checks, marketplace firebreak checks, and line-ending/diff checks.
- R3. The release gate must optionally run live Codex/GHCP evals when the
  required CLIs are authenticated; skipped live evals must be reported as
  `skipped-explicit`, not silently green.

**Proof Output**
- R4. The gate must produce a compact result summary showing pass/fail/skipped
  state per proof family.
- R5. Any green release result must distinguish observed proof from
  self-reported/model-reported proof.
- R6. The gate must fail on required release regressions, not merely report
  them.

**Trace Honesty**
- R7. Release docs must keep `observed_trace` scoped to command/write/delete
  capture and explicitly say file reads/tools/internal APIs are not fully
  observed in v1.

## Success Criteria

- A maintainer can run one command before global sync and see whether release
  proof passed, failed, or skipped live-only surfaces.
- A skipped live eval cannot masquerade as fully verified.
- Existing default `kb-check -All` remains fast and deterministic.

## Scope Boundaries

- Do not make live model calls part of default `kb-check -All`.
- Do not attempt syscall/file-read tracing in this workstream.
- Do not require network or external CLI auth for ordinary local development.

## Key Decisions

- Keep default and release gates separate: avoids turning every local check into
  a costly live-model run. Evidence: existing docs and runner behavior.
- First target includes both profiles: `local-release` for deterministic release
  confidence and optional `live-release` for Codex/GHCP live evals when the CLIs
  are authenticated.

## Dependencies / Assumptions

- Assumption: release gate will be PowerShell-first unless the cross-platform
  workstream changes the toolchain strategy.
- Assumption: `codex` and GHCP CLIs may be unavailable or unauthenticated on
  some runs.

## Alternatives Considered

- Put live evals in `kb-check -All`: rejected because normal checks need to
  stay deterministic and cheap.
- Leave release proof manual: rejected unless user parks this stream, because
  it is the most direct remaining confidence gap.

## Slice Candidates (advisory for /kb-plan)

- Release gate command - add a scripted profile that composes existing proof
  commands and records pass/fail/skipped.
- Live eval optional wiring - add explicit live-eval switches with honest skip
  states.
- Release proof docs - document how to interpret observed/self-reported/skipped
  proof before global sync.

## Outstanding Questions

### Resolve Before Planning

- None.

### Deferred to Planning

- [Affects R4][Technical] Decide exact result artifact path and summary format.
- [Affects R3][Technical] Detect CLI auth availability without causing noisy
  failures.

## Next Steps

-> /kb-plan
