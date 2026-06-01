---
date: 2026-06-01
topic: skill-surface-minimality
brainstorm_style: kb-brainstorm
---

# Skill Surface Minimality Proof

## Problem Frame

Claude's remaining criticism says the bundle still carries long hot-path skills
and a large reviewer-agent surface. The repo already values "every token pays
rent", but deletion without proof previously broke review dispatch. This stream
defines how to prove what is load-bearing before trimming or deleting.

## Research Summary

**Findings that shaped requirements:**
- `kb-check -All` currently reports long-skill warnings for hot-path skills.
- `README.md` documents about 36 skills plus 52 reviewer/specialist agents and
  explains that some inherited ATV agents are retained because deletion broke
  dispatch.
- `scripts/skill-surface-report.ps1` reports route-level loaded surface.
- `docs/context/PROJECT.md` explicitly says not to remove reviewer agents until
  an eval proves no workflow dispatches them.

**Confidence:** High - local evidence identifies the problem and the existing
measurement tool.

## Requirements

**Agent Load-Bearing Proof**
- R1. Add an eval/report that maps each workflow skill to the reviewer/specialist
  agents it can dispatch.
- R2. Identify agents that are required, conditionally required, inherited but
  unproven, or unused.
- R3. Do not delete agents solely from static absence unless runtime dispatch or
  fixture proof shows they are unused.

**Long Skill Trim**
- R4. Use loaded-surface measurements to rank hot-path trim targets before
  editing long skills.
- R5. Trim by moving phase-specific detail into lazy references only when the
  route behavior and proof gates remain intact.
- R6. Any trim must preserve route fixtures, sync checks, and completion/review
  behavior.

**Deletion Safety**
- R7. Produce a deletion candidate list with expected line/token reduction and
  required proof command for each candidate.
- R8. Every deletion or trim must have a rollback-safe diff and deterministic
  proof.

## Success Criteria

- The repo can say which reviewer agents are load-bearing vs candidates for
  removal.
- Long-skill warnings shrink only after behavior-preserving proof.
- Token reduction is measured, not asserted.

## Scope Boundaries

- Do not delete `kb-review`, `ce-review`, `ce-compound`, or
  `ce-compound-refresh` unless callers are rewritten first.
- Do not remove agents from globals or ATV copies before repo source and sync
  policy agree.
- Do not optimize for line count if it weakens safety gates.

## Key Decisions

- Proof before deletion: prior removal broke review dispatch. Evidence:
  `README.md` and `docs/context/PROJECT.md`.
- First target is conservative: classify load-bearing agents/skills first, with
  no deletion in the near-term release hardening pass.
- Trim/deletion execution belongs in a separate cold-storage plan to run later
  after release confidence exists.

## Dependencies / Assumptions

- Assumption: release proof should exist before aggressive deletion so a green
  run means more than "lint passed".

## Alternatives Considered

- Delete inherited ATV agents now: rejected because dispatch breakage is already
  known.
- Keep all long skills forever: rejected because startup/token cost remains a
  valid criticism.

## Slice Candidates (advisory for /kb-plan)

- Agent dispatch inventory - static/runtime mapping of skills to agents.
- Minimality report - classify agents and long skills by deletion/trim risk.
- Cold-storage trim/deletion queue - later plan for actual removals after proof.

## Outstanding Questions

### Resolve Before Planning

- None.

### Deferred to Planning

- [Affects R1][Technical] Decide whether the first agent inventory is static
  `rg`/frontmatter analysis, runtime fixture dispatch, or both.
- [Affects R4][Technical] Decide which route surface budget should become the
  first warning/failure threshold.

## Next Steps

-> /kb-plan for classification work; park trim/deletion execution in cold storage
