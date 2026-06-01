---
date: 2026-06-01
topic: upstream-selective-sync
brainstorm_style: kb-brainstorm
---

# Upstream Selective Sync Automation

## Problem Frame

The repo now says original ATV upstream is a source to mine, not a mirror target.
That policy is right, but manual selective review can become friction. This
stream decides whether to script the comparison/triage flow so safe selective
sync is faster than accidental mirroring or stale drift.

## Research Summary

**Findings that shaped requirements:**
- `docs/context/epics/atv-upstream-resync.md` records the selective sync policy.
- `docs/context/research/2026-05-31-atv-upstream-skill-delta.md` records the
  previous ATV delta and superseded workflow cleanup.
- `README.md` says there is no automatic upstream merge bot; upstream fixes are
  deliberate sync/review tasks.

**Confidence:** High - the policy exists; automation does not.

## Requirements

**Selective Triage**
- R1. Provide a scripted report that compares working repo, local ATV fork, and
  original ATV upstream by skill category.
- R2. Classify upstream changes as KB-owned reject, shared overlap merge-review,
  ATV-native candidate, superseded workflow reject/park, or unknown.
- R3. The script must not mutate working trees by default.

**Safe Promotion**
- R4. Accepted upstream changes must point to source commit/path and target copy
  paths.
- R5. Rejected changes must record rationale so the same import is not repeated.
- R6. The flow must preserve local OSV/security additions unless a human
  explicitly accepts an upstream replacement.

## Success Criteria

- Running one command gives a reviewable upstream delta without checkout churn.
- A tired maintainer is less likely to bulk-copy upstream or miss useful review
  improvements.

## Scope Boundaries

- Do not build a bot that auto-merges upstream into `E:\all-the-vibes`.
- Do not auto-install upstream skills globally.
- Do not revive superseded `lfg`, `slfg`, or `workflows-*` routes without an app
  use case.

## Key Decisions

- Selective source mining is the policy. Evidence:
  `docs/context/epics/atv-upstream-resync.md`.
- First automation target is read-only reporting only. It should explain upstream
  deltas clearly without copying, applying, or installing anything.

## Dependencies / Assumptions

- Assumption: `E:\all-the-vibes` has `upstream` configured to original ATV.
- Assumption: reports can use `git show`/`git diff` object reads to avoid dirty
  checkout mutation.

## Alternatives Considered

- Keep manual: acceptable if upstream sync is rare.
- Auto-merge upstream: rejected because it conflicts with KB overlay ownership.

## Slice Candidates (advisory for /kb-plan)

- Upstream delta report - category-based report from git object reads.
- Decision ledger - append accepted/rejected/parked rationale to research or a
  sync log.
- Optional apply mode - copy only explicitly approved paths after report review.

## Outstanding Questions

### Resolve Before Planning

- None.

### Deferred to Planning

- [Affects R2][Technical] Decide category config format and where to keep
  superseded-skill denylist.

## Next Steps

-> /kb-plan
