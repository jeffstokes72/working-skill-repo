# Claude Remaining Hardening

Status: completed
Created: 2026-06-01
Last refreshed: 2026-06-01

## Intent

Close the remaining valid criticism from the external review without bloating
the KB workflow or chasing theoretical purity. The goal is to make the bundle
safer to release globally, cheaper to load, and more honest about proof limits.

## Success Criteria

- A release/confidence gate exists or is explicitly parked.
- Reviewer-agent and long-skill deletion decisions are backed by eval proof
  rather than vibe.
- Cross-platform support is either real enough to claim or explicitly scoped to
  PowerShell 7.
- Original ATV upstream sync remains selective and fast enough that the safe
  path is the default path.
- Every runnable workstream has a manifest; every non-runnable workstream has a
  named blocker or parked rationale.

## Architecture Decisions

- Do not put live model evals in default `kb-check -All`; they require explicit
  auth, time, and cost.
- Treat `observed_trace` v1 as command/write/delete proof, not complete syscall
  tracing.
- Do not delete reviewer agents until an eval proves dispatch does not need
  them.
- Do not port the harness to Node/Python unless portability becomes a real
  consumer requirement.
- Do not mirror original ATV upstream; mine it for useful changes.

## Research

- Local context: `todo.md`, `docs/context/PROJECT.md`,
  `docs/context/operations/testing.md`, `evals/skill-eval/README.md`,
  `README.md`.
- External research skipped: these are local workflow/tooling decisions, and
  current docs already capture the relevant critique.

## Workstreams

| Workstream | Brainstorm | Manifest | Status | Notes |
|---|---|---|---|---|
| Release confidence gate | `docs/brainstorms/2026-06-01-release-confidence-gate-requirements.md` | `docs/plans/2026-06-01-080-kb-claude-remaining-hardening-manifest.md` | completed | Local/live profiles exist; live remains explicit. |
| Skill surface minimality proof | `docs/brainstorms/2026-06-01-skill-surface-minimality-requirements.md` | `docs/plans/2026-06-01-080-kb-claude-remaining-hardening-manifest.md` | completed | Conservative classification exists; protected repo-policy skills are not deletion candidates. |
| Cross-platform tooling path | `docs/brainstorms/2026-06-01-cross-platform-tooling-requirements.md` | `docs/plans/2026-06-01-083-tool-go-core-gate-wrapper-plan.md` | completed | Thin Go wrapper exists; it delegates to PowerShell and is not a full harness port. |
| Upstream selective sync automation | `docs/brainstorms/2026-06-01-upstream-selective-sync-requirements.md` | `docs/plans/2026-06-01-080-kb-claude-remaining-hardening-manifest.md` | completed | Read-only upstream delta report exists; no apply mode. |
| Trim/deletion execution | skipped-clear | `docs/plans/2026-06-01-085-cold-trim-deletion-queue-plan.md` | completed | No deletion was justified; remaining candidates need runtime proof or focused trimming. |

## Dependency Map

```text
Release confidence gate
  -> Skill surface minimality proof
  -> Cross-platform tooling path
  -> Upstream selective sync automation
```

Release proof should come before aggressive trimming or deletion. Portability
and upstream automation can be planned independently if the user chooses to do
them now.

## Execution Queue

Runnable after planning:

- None. This epic is complete.

## Human Checkpoints

None.

## Parked / Blocked

- Full file-read/syscall tracing is parked unless the release gate proves
  command/write/delete capture is insufficient.
- Full Go harness rewrite is parked; the current Go wrapper is intentionally
  thin and still delegates to PowerShell.
- Upstream apply mode is parked until the read-only delta report proves useful.
- Runtime-usage proof for the remaining cold-storage candidates is parked until
  a focused deletion or trim plan is opened.

## Completion Criteria

- Every workstream is planned, parked, blocked, or done.
- `todo.md` points at this epic and any created manifests.
- Planning ends with the standard `kb-epic` execution question.
